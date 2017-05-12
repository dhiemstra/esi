require "oauth2"
require "forwardable"
require "ostruct"
require "addressable/uri"

module Esi
  autoload :Version,     'esi/version'
  autoload :AccessToken, 'esi/access_token'
  autoload :OAuth,       'esi/o_auth'
  autoload :Calls,       'esi/calls'
  autoload :Client,      'esi/client'
  autoload :Response,    'esi/response'

  DEFAULT_CONFIG = {
    datasource: :tranquility,
    oauth_host: 'https://login.eveonline.com',
    api_host: 'https://esi.tech.ccp.is',
    api_version: :latest,
    log_level: :info,
    log_target: STDOUT,
    response_log_path: nil,
    client_id: nil,
    client_secret: nil
  }

  class << self
    attr_writer :api_version, :logger

    def config
      @config ||= OpenStruct.new(DEFAULT_CONFIG)
    end

    def logger
      @logger ||= Esi.config.logger || Logger.new(Esi.config.log_target).tap do |l|
        l.level = Logger.const_get(Esi.config.log_level.upcase)
      end
    end

    def api_version
      @api_version || :latest
    end

    def classify(word)
      word.to_s.split('_').map(&:capitalize).join
    end

    def generate_url(path, params={})
      path = path[1..-1] if path.start_with?('/')
      path += "/" unless path.end_with?('/')

      url = [config.api_host, config.api_version, path].join('/')
      uri = Addressable::URI.parse(url)
      uri.query_values = {datasource: config.datasource}.merge(params.to_h)
      uri.to_s
    end
  end

  class ApiError < OAuth2::Error
    attr_reader :key, :message, :type

    def initialize(response)
      super(response.original_response)

      @code = response.original_response.status
      @key = response.data[:key]
      @message = response.data[:message] && response.data[:message].presence ? response.data[:message] : response.data[:error]
      @type = response.data[:exceptionType]
    end
  end

  class ApiUnknownError < ApiError; end
  class ApiNotFoundError < ApiError; end
  class ApiForbiddenError < ApiError; end
  class Error < StandardError; end
end
