module Esi
  class Client
    MAX_ATTEMPTS = 3

    attr_accessor :refresh_callback, :access_token, :refresh_token, :expires_at
    attr_reader :logger, :oauth

    def initialize(token: nil, refresh_token: nil, expires_at: nil)
      @logger = Esi.logger
      @token = token
      @refresh_token = refresh_token
      @expires_at = expires_at
    end

    def method_missing(name, *args, &block)
      klass = nil
      ActiveSupport::Notifications.instrument('esi.client.detect_call') do
        class_name = name.to_s.split('_').map(&:capitalize).join
        begin
          klass = Esi::Calls.const_get(class_name)
        rescue NameError
          super(name, *args, &block)
        end
      end

      call = klass.new(*args)
      call.paginated? ? request_paginated(call, &block) : request(call, &block)
    end

    def log(message)
      logger.info message
    end

    def debug(message)
      logger.debug message
    end

    private

    def oauth
      @oauth ||= OAuth.new(
        access_token: @token,
        refresh_token: @refresh_token,
        expires_at: @expires_at,
        callback: -> (token, expires_at) {
          @token = token
          @expires_at = expires_at
          if refresh_callback.respond_to?(:call)
            refresh_callback.call(token, expires_at)
          end
        }
      )
    end

    def request_paginated(call, &block)
      response = nil
      page = 1

      ActiveSupport::Notifications.instrument('esi.client.request.paginated') do
        loop do
          call.page = page
          page_response = request(call, &block)

          if page_response.data.blank?
            break
          elsif response
            response.merge(page_response)
          else
            response = page_response
          end

          page += 1
        end
      end

      response
    end

    def request(call, &block)
      response = nil
      last_ex = nil
      options = { timeout: Esi.config.timeout }
      url ||= call.url

      debug "Starting request: #{url}"

      ActiveSupport::Notifications.instrument('esi.client.request') do
        1.upto(MAX_ATTEMPTS) do |try|
          last_ex = nil

          begin
            response = Timeout::timeout(Esi.config.timeout) do
              oauth.request(call.method, url, options)
            end
          rescue Faraday::SSLError, Faraday::ConnectionFailed, Timeout::Error, Net::ReadTimeout => e
            last_ex = e
            logger.error e.to_s
            sleep 3
            next
          rescue OAuth2::Error => e
            last_ex = e

            case e.response.status
            when 502 # Temporary server error
              logger.error "TemporaryServerError, sleeping for 15 seconds"
              sleep 15
              next
            when 503 # Rate Limit
              logger.error "RateLimit error, sleeping for 15 seconds"
              sleep 15
              next
            when 404 # Not Found
              raise Esi::ApiNotFoundError.new(Response.new(e.response, call))
            when 403 # Forbidden
              response = Response.new(e.response, call)
              debug_error('ApiForbiddenError', url, e.response)
              raise Esi::ApiForbiddenError.new(response)
            when 400 # Bad Request
              response = Response.new(e.response, call)
              case response.error
              when 'invalid_token'
                debug_error('ApiRefreshTokenExpiredError ', url, response)
                raise Esi::ApiRefreshTokenExpiredError.new(response)
              when 'invalid_client'
                debug_error('ApiInvalidAppClientKeysError', url, response)
                raise Esi::ApiInvalidAppClientKeysError.new(response)
              else
                debug_error('ApiBadRequestError', url, response)
                raise Esi::ApiBadRequestError.new(response)
              end
            else
              response = Response.new(e.response, call)
              debug_error('ApiUnknownError', url, response)
              raise Esi::ApiUnknownError.new(response)
            end
          end

          break if response
        end
      end

      if last_ex
        logger.error "Request failed with #{last_ex.class}"
        raise Esi::ApiRequestError.new(last_ex)
      end

      debug "Request successful"

      ActiveSupport::Notifications.instrument('esi.client.response.render') do
        response = Response.new(response, call)
        response.save
      end
      ActiveSupport::Notifications.instrument('esi.client.response.callback') do
        response.data.each { |item| block.call(item) } if block
      end
      response
    end

    def debug_error(klass, url, response)
      logger.error "#{klass}(#{response.error}) status: #{response.status}) - url: #{url}"
    end
  end
end
