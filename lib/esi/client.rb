# frozen_string_literal: true

module Esi
  # The Esi Client class
  # @!attribute [rw] refresh_callback
  #  @return [#callback] the refresh_token callback method
  # @!attribute [rw] access_token
  #  @return [String] the esi access_token
  # @!attribute [rw] refresh_token
  #  @return [String] the esi refresh_token string
  # @!attribute [rw] expires_at
  #  @return [Time] the timestamp of the esi token expire
  # @!attribute [r] logger
  #  @return [Logger] the logger class for the gem
  # @!attribute [r] oauth
  #  @return [Esi::Oauth] the oauth instance for the client
  class Client
    # @return [Fixnum] The max amount of request attempst Client will make
    MAX_ATTEMPTS = 2

    attr_accessor :refresh_callback, :access_token, :refresh_token, :expires_at
    attr_reader :logger, :oauth

    # Create a new instance of Client
    # @param token [String] token the esi access_token
    # @param refresh_token [String] refresh_token the esi refresh_token
    # @param expires_at [Time] expires_at the time stamp the esi token expires_at
    # @param oauth_client [OAuth2::Client] Custom instance of OAuth2::Client
    def initialize(token: nil, refresh_token: nil, expires_at: nil, oauth_client: nil)
      @logger = Esi.logger
      @access_token = token
      @refresh_token = refresh_token
      @expires_at = expires_at
      @oauth_client = oauth_client
      @oauth = init_oauth
    end

    # Set the current thread's `Esi::Client`
    #
    # @param client [Esi::Client] the client to set
    #
    # @return [Esi::Client] the current thread's `Esi::Client`
    def self.current=(client)
      Thread.current[:esi_client] = client
    end

    # Get the current thread's `Esi::Client`
    # @return [Esi::Client] the current thread's `Esi::Client`
    def self.current
      Thread.current[:esi_client] ||= new
    end

    # Switch to default Esi::Client (Esi::Client.new)
    # @return [Esi::Client] the current thread's `Esi::Client`
    def self.switch_to_default
      self.current = new
    end

    # Switch current thread's client to instance of Esi::Client
    # @return [self] the instance calling switch to
    def switch_to
      Esi::Client.current = self
    end

    # Yield block with instance of Esi::Client and revert to
    #  previous client or default client
    #
    # @example Call an Esi::Client method using an instance of client
    #  new_client = Esi::Client.new(token: 'foo', refresh_token: 'foo', expires_at: 30.minutes.from_now)
    #  new_client.with_client do |client|
    #    client.character(1234)
    #  end
    #  #=> Esi::Response<#>
    #
    # @yieldreturn [#block] the passed block.
    def with_client
      initial_client = Esi::Client.current
      switch_to
      yield(self) if block_given?
    ensure
      initial_client.switch_to if initial_client
      Esi::Client.switch_to_default unless initial_client
    end

    # Intercept Esi::Client method_missing and attempt to call an Esi::Request
    #  with an Esi::Calls
    #
    # @param name [Symbol|String] name the name of the method called
    # @param args [Array] *args the arguments to call the method with
    # @param block [#block] &block the block to pass to the underlying method
    # @raise [NameError] If the Esi::Calls does not exist
    # @return [Esi::Response] the response given for the call
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

    # Test if the Esi::Client has a method
    # @param [Symbol] name the name of the method to test
    # @return [Boolean] wether or not the method exists
    def method?(name)
      begin
        klass = Esi::Calls.const_get(method_to_class_name(name))
      rescue NameError
        return false
      end
      !klass.nil?
    end

    # Test if the Esi::Client has a pluralized version of a method
    # @param [Symbol] name the name of the method to test
    # @return [Boolean] wether or not the pluralized method exists
    def plural_method?(name)
      plural = name.to_s.pluralize.to_sym
      method? plural
    end

    # Log a message
    # @param [String] message the message to log
    # @return [void] the Logger.info method with message
    def log(message)
      logger.info message
    end

    # Log a message with debug
    # @param [String] message the message to log
    # @return [void] the Logger.debug method with message
    def debug(message)
      logger.debug message
    end

    private

    def make_call(call, &block)
      call.paginated? ? request_paginated(call, &block) : request(call, &block)
    end

    def cached_response(klass, *args, &block)
      call = klass.new(*args)
      Esi.cache.fetch(call.cache_key, expires_in: klass.cache_duration) do
        make_call(call, &block)
      end
    end

    def method_to_class_name(name)
      name.dup.to_s.split('_').map(&:capitalize).join
    end

    # rubocop:disable Metrics/MethodLength
    def init_oauth
      @oauth ||= OAuth.new(
        access_token: @access_token,
        refresh_token: @refresh_token,
        expires_at: @expires_at,
        client: @oauth_client,
        callback: lambda { |token, expires_at|
          @access_token = token
          @expires_at = expires_at
          refresh_callback.call(token, expires_at) if refresh_callback.respond_to?(:call)
        }
      )
    end
    # rubocop:enable Metrics/MethodLength

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

    # @todo esi should not retry
    # @todo make rubocop compliant
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
