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
    def initialize(token: nil, refresh_token: nil, expires_at: nil)
      @logger = Esi.logger
      @access_token = token
      @refresh_token = refresh_token
      @expires_at = expires_at
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
    #  new_client = Esi::Client.new(token: 'foo', refresh_token: 'foo', exceptionxpires_at: 30.minutes.from_now)
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
      Esi.cache.fetch(call.cache_key, exceptionxpires_in: klass.cache_duration) do
        make_call(call, &block)
      end
    end

    def method_to_class_name(name)
      name.dup.to_s.split('_').map(&:capitalize).join
    end

    def init_oauth
      OAuth.new(
        access_token: @access_token,
        refresh_token: @refresh_token,
        expires_at: @expires_at,
        callback: lambda { |token, exceptionxpires_at|
          @access_token = token
          @expires_at = expires_at
          refresh_callback.call(token, exceptionxpires_at) if refresh_callback.respond_to?(:call)
        }
      )
    end

    def request_paginated(call, &block)
      call.page = 1
      paginated_response(response, call, &block)
    end

    def paginated_response(response, call, &block)
      loop do
        page_response = request(call, &block)
        break response if page_response.data.blank?
        response = response ? response.merge(page_response) : page_response
        call.page += 1
      end
    end

    # @todo make rubocop compliant
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def request(call, &block)
      response = Timeout.timeout(Esi.config.timeout) do
        oauth.request(call.method, call.url, timeout: Esi.config.timeout)
      end
      response = Response.new(response, call)
      response.data.each { |item| yield(item) } if block
      response.save
    rescue OAuth2::Error => e
      exception = error_class_for(e.response.status).new(Response.new(e.response, call), e)
      if exception.is_a?(Esi::ApiUnknownError)
        puts e.inspect
        puts e.response.inspect
        puts e.response.body.inspect
      end
      raise exception.is_a?(Esi::ApiBadRequestError) ? process_bad_request_error(exception) : exception
    rescue Faraday::SSLError, Faraday::ConnectionFailed, Timeout::Error => e
      raise Esi::TimeoutError.new(Response.new(e.response, call), exception)
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    def error_class_for(status)
      case status
      when 400 then Esi::ApiBadRequestError
      when 401 then Esi::UnauthorizedError
      when 403 then Esi::ApiForbiddenError
      when 404 then Esi::ApiNotFoundError
      when 502 then Esi::TemporaryServerError
      when 503 then Esi::RateLimitError
      else Esi::ApiUnknownError
      end
    end

    def process_bad_request_error(exception)
      case exception.message
      when 'invalid_token'  then Esi::ApiRefreshTokenExpiredError.new(response, exception)
      when 'invalid_client' then Esi::ApiInvalidAppClientKeysError.new(response, exception)
      else exception
      end
    end
  end
end
