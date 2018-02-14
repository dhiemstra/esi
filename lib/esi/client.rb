# frozen_string_literal: true

require 'active_support/core_ext/string'
require 'set'

module Esi
  class Client
    MAX_ATTEMPTS = 2

    attr_accessor :refresh_callback, :access_token, :refresh_token, :expires_at
    attr_reader :logger, :oauth

    def initialize(token: nil, refresh_token: nil, expires_at: nil)
      @logger = Esi.logger
      @access_token = token
      @refresh_token = refresh_token
      @expires_at = expires_at
      @oauth = init_oauth
    end

    def self.current=(client)
      Thread.current[:esi_client] = client
    end

    def self.current
      Thread.current[:esi_client] ||= new
    end

    def self.switch_to_default
      self.current = new
    end

    def switch_to
      Esi::Client.current = self
    end

    def with_client
      initial_client = Esi::Client.current
      switch_to
      yield if block_given?
    ensure
      initial_client.switch_to if initial_client
      Esi::Client.switch_to_default unless initial_client
    end

    def method_missing(name, *args, &block)
      klass = nil
      ActiveSupport::Notifications.instrument('esi.client.detect_call') do
        class_name = method_to_class_name name
        begin
          klass = Esi::Calls.const_get(class_name)
        rescue NameError
          super(name, *args, &block)
        end
      end
      cached_response(klass, *args, &block)
    end

    def method?(name)
      begin
        klass = Esi::Calls.const_get(method_to_class_name(name))
      rescue NameError
        return false
      end
      !klass.nil?
    end

    def plural_method?(name)
      plural = name.to_s.pluralize.to_sym
      method? plural
    end

    def log(message)
      logger.info message
    end

    def debug(message)
      logger.debug message
    end

    private

    def make_call(call, &block)
      call.paginated? ? request_paginated(call, &block) : request(call, &block)
    end

    def cached_response(klass, *args, &block)
      call = klass.new(*args)
      return make_call(call, &block) unless Esi.cache
      cache_key = [klass.name, args].flatten.to_set.hash
      Esi.cache.fetch(cache_key, expires_in: klass.cache_duration) do
        make_call(call, &block)
      end
    end

    def method_to_class_name(name)
      name.dup.to_s.split('_').map(&:capitalize).join
    end

    def init_oauth
      @oauth ||= OAuth.new(
        access_token: @access_token,
        refresh_token: @refresh_token,
        expires_at: @expires_at,
        callback: lambda { |token, expires_at|
          @access_token = token
          @expires_at = expires_at
          refresh_callback.call(token, expires_at) if refresh_callback.respond_to?(:call)
        }
      )
    end

    def request_paginated(call, &block)
      call.page = 1
      response = nil
      ActiveSupport::Notifications.instrument('esi.client.request.paginated') do
        response = paginated_response(response, call, &block)
      end
      response
    end

    def paginated_response(response, call, &block)
      loop do
        page_response = request(call, &block)
        break response if page_response.data.blank?
        response = response ? response.merge(page_response) : page_response
        call.page += 1
      end
    end

    # FIXME: esi should not retry
    # FIXME: make rubocop compliant
    # rubocop:disable Lint/ShadowedException
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/BlockLength
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity
    def request(call, &block)
      response = nil
      last_ex = nil
      options = { timeout: Esi.config.timeout }
      url ||= call.url

      debug "Starting request: #{url}"

      ActiveSupport::Notifications.instrument('esi.client.request') do
        1.upto(MAX_ATTEMPTS) do |_try|
          last_ex = nil
          response = nil

          begin
            response = Timeout.timeout(Esi.config.timeout) do
              oauth.request(call.method, url, options)
            end
          rescue Faraday::SSLError, Faraday::ConnectionFailed, Timeout::Error, Net::ReadTimeout => e
            last_ex = e
            logger.error e.to_s
            sleep 3
            next
          rescue OAuth2::Error => e
            last_ex = e
            response = Response.new(e.response, call)

            case e.response.status
            when 502 # Temporary server error
              logger.error "TemporaryServerError: #{response.error}"
              sleep 5
              next
            when 503 # Rate Limit
              logger.error 'RateLimit error, sleeping for 5 seconds'
              sleep 5
              next
            when 404 # Not Found
              raise Esi::ApiNotFoundError.new(Response.new(e.response, call), e)
            when 403 # Forbidden
              debug_error('ApiForbiddenError', url, response)
              raise Esi::ApiForbiddenError.new(response, e)
            when 400 # Bad Request
              exception = Esi::ApiBadRequestError.new(response, e)
              case exception.message
              when 'invalid_token'
                debug_error('ApiRefreshTokenExpiredError ', url, response)
                raise Esi::ApiRefreshTokenExpiredError.new(response, e)
              when 'invalid_client'
                debug_error('ApiInvalidAppClientKeysError', url, response)
                raise Esi::ApiInvalidAppClientKeysError.new(response, e)
              else
                debug_error('ApiBadRequestError', url, response)
                raise exception
              end
            else
              debug_error('ApiUnknownError', url, response)
              raise Esi::ApiUnknownError.new(response, e)
            end
          end

          break if response
        end
      end
      # rubocop:enable Lint/ShadowedException
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/BlockLength
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/PerceivedComplexity

      if last_ex
        logger.error "Request failed with #{last_ex.class}"
        debug_error(last_ex.class, url, response)
        raise Esi::ApiRequestError, last_ex
      end

      debug 'Request successful'

      ActiveSupport::Notifications.instrument('esi.client.response.render') do
        response = Response.new(response, call)
        response.save
      end
      ActiveSupport::Notifications.instrument('esi.client.response.callback') do
        response.data.each { |item| yield(item) } if block
      end
      response
    end

    def debug_error(klass, url, response)
      [
        '-' * 60,
        "#{klass}(#{response.error})",
        "STATUS: #{response.status}",
        "MESSAGE: #{debug_message_for_response(response)}",
        "URL: #{url}",
        '-' * 60
      ].each { |msg| logger.error(msg) }
    end

    def debug_message_for_response(response)
      response.respond_to?(:data) ? (response.data[:message].presence || response.data[:error]) : response.try(:body)
    end
  end
end
