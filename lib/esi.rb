# frozen_string_literal: true

require 'oauth2'
require 'forwardable'
require 'ostruct'
require 'addressable/uri'
require 'active_support/notifications'

# The main Esi Module
# @!attribute [w] api_version
#  @return [Symbol] the Esi Api version used by the gem
# @!attribute [w] logger
#  @return [Logger] the logger class for the gem
module Esi
  autoload :VERSION,     'esi/version'
  autoload :AccessToken, 'esi/access_token'
  autoload :OAuth,       'esi/o_auth'
  autoload :Calls,       'esi/calls'
  autoload :Client,      'esi/client'
  autoload :Response,    'esi/response'

  require_relative 'esi/api_error'

  # Default ESI access scopes
  # @return [Array<String>] the default scopes
  SCOPES = %w(
    esi-assets.read_assets.v1
    esi-bookmarks.read_character_bookmarks.v1
    esi-calendar.read_calendar_events.v1
    esi-calendar.respond_calendar_events.v1
    esi-characters.read_agents_research.v1
    esi-characters.read_blueprints.v1
    esi-characters.read_chat_channels.v1
    esi-characters.read_contacts.v1
    esi-characters.read_corporation_roles.v1
    esi-characters.read_fatigue.v1
    esi-characters.read_loyalty.v1
    esi-characters.read_medals.v1
    esi-characters.read_opportunities.v1
    esi-characters.read_standings.v1
    esi-characters.write_contacts.v1
    esi-clones.read_clones.v1
    esi-clones.read_implants.v1
    esi-contracts.read_character_contracts.v1
    esi-corporations.read_corporation_membership.v1
    esi-corporations.read_structures.v1
    esi-corporations.track_members.v1
    esi-corporations.write_structures.v1
    esi-fittings.read_fittings.v1
    esi-fittings.write_fittings.v1
    esi-fleets.read_fleet.v1
    esi-fleets.write_fleet.v1
    esi-industry.read_character_jobs.v1
    esi-killmails.read_killmails.v1
    esi-location.read_location.v1
    esi-location.read_online.v1
    esi-location.read_ship_type.v1
    esi-mail.organize_mail.v1
    esi-mail.read_mail.v1
    esi-mail.send_mail.v1
    esi-markets.read_character_orders.v1
    esi-markets.structure_markets.v1
    esi-planets.manage_planets.v1
    esi-search.search_structures.v1
    esi-skills.read_skillqueue.v1
    esi-skills.read_skills.v1
    esi-ui.open_window.v1
    esi-ui.write_waypoint.v1
    esi-universe.read_structures.v1
    esi-wallet.read_character_wallet.v1
    esi-wallet.read_corporation_wallets.v1
  ).freeze

  # The default Esi gem configuration
  # @return [Hash{Symbol => Symbol|String|Fixnum|Object|Array}] the default configuration
  DEFAULT_CONFIG = {
    datasource: :tranquility,
    oauth_host: 'https://login.eveonline.com',
    api_host: 'https://esi.tech.ccp.is',
    api_version: :latest,
    log_level: :info,
    log_target: STDOUT,
    response_log_path: nil,
    timeout: 60,
    client_id: nil,
    client_secret: nil,
    cache: nil,
    scopes: SCOPES
  }.freeze

  class << self
    attr_writer :api_version, :logger

    # The Esi Configuration
    # @return [OpenStruct] the configuration object
    def config
      @config ||= OpenStruct.new(DEFAULT_CONFIG)
    end

    # The Esi logger class instance
    # @return [MyLoggerInstance|Logger] an instance of the logger class
    def logger
      @logger ||= Esi.config.logger || Logger.new(Esi.config.log_target).tap do |l|
        l.level = Logger.const_get(Esi.config.log_level.upcase)
      end
    end

    # The Esi cache class instance
    # @return [ActiveSupport::Cache::Store] an instance of cache
    def cache
      Esi.config.cache
    end

    # The Esi Api version to interface with
    # @return [Symbol] the esi api version
    def api_version
      @api_version || :latest
    end

    # Generate an Esi url for a given path
    # @param [String] path the path to generate an esi url for
    # @param [Hash{Symbol => String|Fixnum}] params the params for the url query
    # @return [String] the generated url
    def generate_url(path, params = {})
      url = url_for_path(path)
      uri = Addressable::URI.parse(url)
      uri.query_values = { datasource: config.datasource }.merge(params.to_h)
      uri.to_s
    end

    # The current Esi client
    # @return [Esi::Client] the current client
    def client
      @client ||= Client.current
    end

    private

    def url_for_path(path)
      path = path[1..-1] if path.start_with?('/')
      path += '/' unless path.end_with?('/')
      [config.api_host, config.api_version, path].join('/')
    end
  end
end
