module Esi
  class Client
    MAX_ATTEMPTS = 5

    attr_accessor :refresh_callback
    attr_reader :logger, :oauth, :access_token, :refresh_token, :expires_at

    def initialize(token: nil, refresh_token: nil, token_expires_at: nil)
      @logger = Esi.logger
      @token = token
      @refresh_token = refresh_token
      @token_expires_at = token_expires_at
    end

    def method_missing(name, *args, &block)
      name = name.to_s.split('_').map(&:capitalize).join
      begin
        klass = Esi::Calls.const_get(name)
      rescue NameError
        super
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
        expires_at: @token_expires_at,
        callback: -> (token, expires_at) {
          @token = token
          @token_expires_at = expires_at
          if refresh_callback.respond_to?(:call)
            refresh_callback.call(token, expires_at)
          end
        }
      )
    end

    def request_paginated(call, &block)
      items = []
      page = 1

      loop do
        call.page = page
        response = request(call, &block)
        break if response.data.blank?
        items += response.data
        page += 1
      end

      items
    end

    def request(call, url=nil, &block)
      response = nil
      url ||= call.url

      debug "Starting request: #{url}"

      1.upto(MAX_ATTEMPTS) do |try|
        begin
          response = oauth.send(call.method, url)
        rescue OAuth2::Error => e
          case e.response.status
          when 502 # Temporary server error
            logger.error "TemporaryServerError, sleeping for 15 seconds"
            sleep 15
            next
          when 503 # Rate Limit
            logger.error "RateLimit error, sleeping for 15 seconds"
            sleep 15
            next
          when 403 # Forbidden
            logger.error "ApiForbiddenError: #{e.response.status}: #{e.response.body}"
            logger.error url
            raise Esi::ApiForbiddenError.new(Response.new(e.response))
          when 404 # Not Found
            raise Esi::ApiNotFoundError.new(Response.new(e.response))
          else
            logger.error "ApiUnknownError (#{e.response.status}): #{url}"
            raise Esi::ApiUnknownError.new(Response.new(e.response))
          end
        end
        break if response
      end

      debug "Request finished"
      response = Response.new(response)

      if Esi.config.response_log_path && Dir.exists?(Esi.config.response_log_path)
        call_name = call.class.to_s.downcase.split('::').last
        folder = Dirname.new(Esi.config.response_log_path).join(call_name)
        FileUtils.mkdir_p(folder)
        File.write(folder.join("#{Time.now.to_i.to_s}.json"), response.to_s)
      end

      response.data.each { |item| block.call(item) } if block
      response
    end
  end
end
