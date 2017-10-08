module Esi
  class Client
    MAX_ATTEMPTS = 5

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
      items = []
      page = 1

      ActiveSupport::Notifications.instrument('esi.client.request.paginated') do
        loop do
          call.page = page
          response = request(call, &block)
          break if response.data.blank?
          items += response.data
          page += 1
        end
      end

      items
    end

    def request(call, url=nil, &block)
      response = nil
      last_ex = nil
      options = { timeout: Esi.config.timeout }
      url ||= call.url

      debug "Starting request: #{url}"

      ActiveSupport::Notifications.instrument('esi.client.request') do
        1.upto(MAX_ATTEMPTS) do |try|
          last_ex = nil

          begin
            response = oauth.request(call.method, url, options)
          rescue Net::ReadTimeout => e
            last_ex = e
            logger.error "ReadTimeout received"
            sleep 2
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
            when 403 # Forbidden
              logger.error "ApiForbiddenError: #{e.response.status}: #{e.response.body}"
              logger.error url
              raise Esi::ApiForbiddenError.new(Response.new(e.response))
            when 404 # Not Found
              raise Esi::ApiNotFoundError.new(Response.new(e.response))
            else
              response = Response.new(e.response)
              logger.error "ApiUnknownError (#{response.status}): #{url}"

              case response.error
              when 'invalid_client' then
                raise ApiInvalidAppClientKeysError.new(response)
              else
                raise Esi::ApiUnknownError.new(response)
              end
            end
          end
          break if response
        end
      end

      debug "Request finished"
      if last_ex
        logger.error "Request failed with #{last_ex.class}"
        raise ApiRequestError.new(last_ex)
      end

      ActiveSupport::Notifications.instrument('esi.client.response.initialize') do
        response = Response.new(response)
      end
      ActiveSupport::Notifications.instrument('esi.client.response.save') do
        if Esi.config.response_log_path && Dir.exists?(Esi.config.response_log_path)
          call_name = call.class.to_s.downcase.split('::').last
          folder = Pathname.new(Esi.config.response_log_path).join(call_name)
          FileUtils.mkdir_p(folder)
          File.write(folder.join("#{Time.now.to_i.to_s}.json"), response.to_s)
        end
      end
      ActiveSupport::Notifications.instrument('esi.client.response.classify') do
        response.data.each { |item| block.call(item) } if block
      end
      response
    end
  end
end
