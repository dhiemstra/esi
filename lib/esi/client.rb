module Esi
  class Client
    MAX_TRIES = 5
    API_HOST = 'https://esi.tech.ccp.is/dev'

    attr_reader :account, :save_responses, :oauth, :logger, :access_token, :refresh_token, :expires_at

    def initialize(token:, refresh_token:, expires_at:, logger: nil)
      @token = token
      @refresh_token = refresh_token
      @token_expires_at = expires_at
      @save_responses = true # Rails.env.development?
      @logger = logger || Logger.new(Rails.root.join('log', 'esi.log'))
      @logger.level = Logger::INFO
    end

    def open_market_details(type_id)
      url = [API_HOST, "/ui/openwindow/marketdetails/?type_id=", type_id].join
      oauth.post(url)
    end

    def method_missing(name, *args, &block)
      begin
        klass = Calls.const_get(name.to_s.camelize)
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

          # @account.update_esi_token!(token: token, expires_at: expires_at)
          puts "TODO: Implement custom hook"
        }
      )
    end

    def request_paginated(call, &block)
      items = []
      page = 1

      loop do
        call.page = page
        response = request(call, &block)
        break if response.items.blank?
        items += response.items
        page += 1
      end

      items
    end

    def request(call, url=nil, &block)
      response = nil
      url ||= call.url

      debug "Starting request: #{url}"

      1.upto(MAX_TRIES) do |try|
        begin
          response = oauth.get(url)
        rescue OAuth2::Error => e
          case e.response.status
          when 503 # Rate Limit
            logger.error "RateLimit error, sleeping for 15 seconds"
            sleep 15
            next
          when 403 # Forbidden
            logger.error "ApiForbiddenError: #{e.response.status}: #{e.response.body}"
            logger.error url
            raise ApiForbiddenError.new(Response.new(e.response))
          when 404 # Not Found
            raise ApiNotFoundError.new(Response.new(e.response))
          else
            logger.error "ApiUnknownError: #{e.response.status}: #{e.response.body}"
            logger.error url
            raise ApiUnknownError.new(Response.new(e.response))
          end
        end
        break if response
      end

      debug "Request finished"

      response = Response.new(response)

      if save_responses
        folder = Rails.root.join('tmp', call.class.to_s.underscore)
        FileUtils.mkdir_p(folder)
        File.write(folder.join("#{Time.now.to_i.to_s}.json"), response.to_s)
      end

      response.items.each { |item| block.call(item) } if block
      response
    end
  end
end
