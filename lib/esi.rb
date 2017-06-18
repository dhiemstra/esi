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

  SCOPES = %w(
    esi-assets.read_assets.v1
    esi-bookmarks.read_character_bookmarks.v1
    esi-clones.read_clones.v1
    esi-skills.read_skillqueue.v1
    esi-skills.read_skills.v1
    esi-wallet.read_character_wallet.v1
    esi-fleets.read_fleet.v1
    esi-fleets.write_fleet.v1
    esi-killmails.read_killmails.v1
    esi-location.read_location.v1
    esi-location.read_ship_type.v1
    esi-mail.organize_mail.v1
    esi-mail.read_mail.v1
    esi-mail.send_mail.v1
    esi-fittings.read_fittings.v1
    esi-fittings.write_fittings.v1
    esi-markets.structure_markets.v1
    esi-markets.read_character_orders.v1
    esi-industry.read_character_jobs.v1
    esi-search.search_structures.v1
    esi-universe.read_structures.v1
    esi-ui.open_window.v1
    esi-ui.write_waypoint.v1
    esi-characters.read_blueprints.v1
    esi-corporations.read_corporation_membership.v1
    esi-corporations.read_structures.v1
    esi-corporations.write_structures.v1
  )
  DEFAULT_CONFIG = {
    datasource: :tranquility,
    oauth_host: 'https://login.eveonline.com',
    api_host: 'https://esi.tech.ccp.is',
    api_version: :latest,
    log_level: :info,
    log_target: STDOUT,
    response_log_path: nil,
    client_id: nil,
    client_secret: nil,
    scopes: SCOPES
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
      @message = response.data[:message].presence || response.data[:error]
      @type = response.data[:exceptionType]
    end
  end

  class ApiUnknownError < ApiError; end
  class ApiInvalidAppClientKeysError < ApiError; end
  class ApiNotFoundError < ApiError; end
  class ApiForbiddenError < ApiError; end
  class Error < StandardError; end
end
