# frozen_string_literal: true

module Esi
  class Calls
    class << self
      def list
        constants.select { |c| Esi::Calls.const_get(c).try(:scope) }.map { |c| c.to_s.underscore.to_sym }
      end
    end

    class Info
      attr_reader :name, :call
      delegate :scope, :cache_duration, to: :call

      def initialize(name)
        @name = name.to_sym
        @call = Calls.const_get(name.to_s.camelize)
      end

      def to_s
        @name.to_s
      end

      def character?
        name.to_s.starts_with?('character')
      end

      def corporation?
        name.to_s.starts_with?('corporat')
      end
    end

    class Base
      CACHE_NAMESPACE = 'esi'

      class_attribute :scope
      class_attribute :cache_duration

      attr_accessor :path, :params

      def cache_key
        @cache_key ||= begin
          cache_args = [CACHE_NAMESPACE, path.gsub(%r{^\/}, ''), params.sort].flatten
          ActiveSupport::Cache.expand_cache_key(cache_args)
        end
      end

      def method
        @method ||= :get
      end

      def url
        Esi.generate_url(path, params)
      end

      def page=(page)
        self.params ||= {}
        self.params[:page] = page
      end

      def paginated?
        !@paginated
      end
    end

    class Regions < Base
      def initialize
        @path = '/universe/regions/'
      end
    end

    class Region < Base
      def initialize(region_id)
        @path = "/universe/regions/#{region_id}"
      end
    end

    class Constellations < Base
      def initialize
        @path = '/universe/constellations/'
      end
    end

    class Constellation < Base
      def initialize(constellation_id)
        @path = "/universe/constellations/#{constellation_id}"
      end
    end

    class SolarSystem < Base
      def initialize(system_id)
        @path = "/universe/systems/#{system_id}"
      end
    end

    class SolarSystems < Base
      def initialize
        @path = '/universe/systems/'
      end
    end

    class Star < Base
      def initialize(star_id)
        @path = "/universe/stars/#{star_id}"
      end
    end

    class Planet < Base
      def initialize(planet_id)
        @path = "/universe/planets/#{planet_id}"
      end
    end

    class Moon < Base
      def initialize(moon_id)
        @path = "/universe/moons/#{moon_id}"
      end
    end

    class Stargate < Base
      def initialize(stargate_id)
        @path = "/universe/stargates/#{stargate_id}"
      end
    end

    class Station < Base
      def initialize(station_id)
        @path = "/universe/stations/#{station_id}"
      end
    end

    class Structures < Base
      def initialize
        @path = '/universe/structures/'
      end
    end

    class Structure < Base
      def initialize(structure_id)
        @path = "universe/structures/#{structure_id}"
      end
    end

    class Types < Base
      def initialize
        @path = '/universe/types'
        @paginated = true
      end
    end

    class Type < Base
      def initialize(type_id)
        @path = "/universe/types/#{type_id}"
      end
    end

    class DogmaAttributes < Base
      def initialize
        @path = '/dogma/attributes/'
      end
    end

    class DogmaAttribute < Base
      def initialize(attribute_id)
        @path = "/dogma/attributes/#{attribute_id}"
      end
    end

    class DogmaEffects < Base
      def initialize
        @path = '/dogma/effects/'
      end
    end

    class DogmaEffect < Base
      def initialize(effect_id)
        @path = "/dogma/effects/#{effect_id}"
      end
    end

    class IndustryFacilities < Base
      self.scope = nil
      self.cache_duration = 3600

      def initialize
        @path = '/industry/facilities'
      end
    end

    class IndustrySystems < Base
      self.scope = nil
      self.cache_duration = 3600

      def initialize
        @path = '/industry/systems'
      end
    end

    class Search < Base
      self.scope = nil
      # https://esi.tech.ccp.is/latest/characters/907452336/search/?categories=structure&datasource=tranquility&search=Kamela&strict=false&token=Fp3ThF7wjvYBIDIIrtWE_Ryjt9BhYwUP75y2EL5Eq9mHPm8tYt9I9NwgZz8o26FFQBKoUToh2DYVc-Q5Ws400g2

      def initialize(character_id: nil, categories:, search:, strict: false)
        @path = (character_id ? "/characters/#{character_id}" : '') + '/search'
        @params = { categories: categories, search: search, strict: strict }
      end
    end

    class StructureOrders < Base
      def initialize(structure_id:)
        @path = "/markets/structures/#{structure_id}"
        @paginated = true
      end
    end

    class CharacterNames < Base
      self.cache_duration = 3600

      def initialize(character_ids)
        @path = '/characters/names'
        @params = { character_ids: character_ids.join(',') }
      end
    end

    class Character < Base
      self.cache_duration = 3600

      def initialize(character_id)
        @path = "/characters/#{character_id}"
      end
    end

    # Cache: 2 minutes
    class CharacterWallet < Base
      self.scope = 'esi-wallet.read_character_wallet.v1'
      self.cache_duration = 120

      def initialize(character_id)
        @path = "/characters/#{character_id}/wallet"
      end
    end

    class CharacterSkills < Base
      self.scope = 'esi-skills.read_skills.v1'
      self.cache_duration = 120

      def initialize(character_id)
        @path = "/characters/#{character_id}/skills"
      end
    end

    class CharacterWalletJournal < Base
      self.scope = 'esi-wallet.read_character_wallet.v1'
      self.cache_duration = 3600

      def initialize(character_id)
        @path = "/characters/#{character_id}/wallet/journal"
      end
    end

    class CharacterWalletTransactions < Base
      self.scope = 'esi-wallet.read_character_wallet.v1'
      self.cache_duration = 3600

      def initialize(character_id)
        @path = "/characters/#{character_id}/wallet/transactions"
      end
    end

    class CharacterOrders < Base
      self.scope = 'esi-markets.read_character_orders.v1'
      self.cache_duration = 3600

      def initialize(character_id)
        @path = "/characters/#{character_id}/orders"
      end
    end

    #################################
    ### IndustryJobs
    #################################
    class CharacterIndustryJobs < Base
      self.scope = 'esi-industry.read_character_jobs.v1'
      self.cache_duration = 300

      def initialize(character_id, with_completed: true)
        @path = "/characters/#{character_id}/industry/jobs"
        @params = { include_completed: with_completed }
      end
    end

    class CorporationIndustryJobs < Base
      self.scope = 'esi-industry.read_corporation_jobs.v1'
      self.cache_duration = 300

      def initialize(corporation_id, with_completed: true)
        @path = "/corporations/#{corporation_id}/industry/jobs"
        @params = { include_completed: with_completed }
      end
    end

    #################################
    ### Blueprints
    #################################
    class CharacterBlueprints < Base
      self.scope = 'esi-characters.read_blueprints.v1'
      self.cache_duration = 3600

      def initialize(character_id)
        @path = "/characters/#{character_id}/blueprints"
      end
    end

    class CorporationBlueprints < Base
      self.scope = 'esi-corporations.read_blueprints.v1'
      self.cache_duration = 3600

      def initialize(corporation_id)
        @path = "/corporations/#{corporation_id}/blueprints"
      end
    end

    #################################
    ### Assets
    #################################
    class CharacterAssets < Base
      self.scope = 'esi-assets.read_assets.v1'
      self.cache_duration = 3600

      def initialize(character_id)
        @path = "/characters/#{character_id}/assets"
        @paginated = true
      end
    end

    class CorporationAssets < Base
      self.scope = 'esi-assets.read_corporation_assets.v1'
      self.cache_duration = 3600

      def initialize(corporation_id)
        @path = "/corporations/#{corporation_id}/assets"
        @paginated = true
      end
    end

    #################################
    ### Contracts
    #################################
    class CharacterContracts < Base
      self.scope = 'esi-contracts.read_character_contracts.v1'
      self.cache_duration = 3600

      def initialize(character_id)
        @path = "/characters/#{character_id}/contracts"
      end
    end

    class ContractItems < Base
      self.scope = 'esi-contracts.read_character_contracts.v1'
      self.cache_duration = 3600

      def initialize(character_id, contract_id)
        @path = "/characters/#{character_id}/contracts/#{contract_id}/items"
      end
    end

    class CharacterLocation < Base
      self.scope = 'esi-location.read_location.v1'
      self.cache_duration = 5

      def initialize(character_id)
        @path = "/characters/#{character_id}/location"
      end
    end

    # characters/{character_id}/online
    # esi-location.read_online.v1
    # 60

    # /characters/{character_id}/attributes
    # esi-skills.read_skills.v1
    # 3600

    # /characters/{character_id}/chat_channels
    # esi-characters.read_chat_channels.v1
    # 300

    # /characters/{character_id}/clones
    # esi-clones.read_clones.v1
    # 120

    # /characters/{character_id}/implants
    # esi-clones.read_implants.v1
    # 3600

    # /characters/{character_id}/roles
    # esi-characters.read_corporation_roles.v1
    # 3600

    class CharacterMail < Base
      self.scope = 'esi-mail.read_mail.v1'
      self.cache_duration = 30

      def initialize(character_id)
        @path = "/characters/#{character_id}/mail"
      end
    end

    class Assets < Base
      self.scope = 'esi-assets.read_assets.v1'
      self.cache_duration = 3600

      def initialize(character_id)
        @path = "/characters/#{character_id}/assets"
      end
    end

    class Alliances < Base
      self.cache_duration = 3600

      def initialize
        @path = '/alliances'
      end
    end

    class AllianceNames < Base
      self.cache_duration = 3600

      def initialize(alliance_ids)
        @path = '/alliances/names'
        @params = { alliance_ids: alliance_ids.join(',') }
      end
    end

    class Alliance < Base
      self.cache_duration = 3600

      def initialize(alliance_id)
        @path = "/alliances/#{alliance_id}"
      end
    end

    class CorporationNames < Base
      self.cache_duration = 3600

      def initialize(corporation_ids)
        @path = '/corporations/names'
        @params = { corporation_ids: corporation_ids.join(',') }
      end
    end

    class Corporation < Base
      self.cache_duration = 3600

      def initialize(corporation_id)
        @path = "/corporations/#{corporation_id}"
      end
    end

    class CorporationStructures < Base
      self.scope = 'esi-corporations.read_structures.v1'
      self.cache_duration = 3600

      def initialize(corporation_id)
        @path = "/corporations/#{corporation_id}/structures"
      end
    end

    class CorporationMembers < Base
      self.scope = 'esi-corporations.read_corporation_membership.v1'
      self.cache_duration = 3600

      def initialize(corporation_id)
        @path = "/corporations/#{corporation_id}/members"
      end
    end

    class CorporationMemberTracking < Base
      self.scope = 'esi-corporations.track_members.v1'
      self.cache_duration = 3600

      def initialize(corporation_id)
        @path = "/corporations/#{corporation_id}/membertracking"
      end
    end

    # Link: https://esi.tech.ccp.is/dev/#!/Corporation/get_corporations_corporation_id_roles
    class CorporationRoles < Base
      self.scope = 'esi-corporations.read_corporation_membership.v1'
      self.cache_duration = 3600

      def initialize(corporation_id)
        @path = "/corporations/#{corporation_id}/roles"
      end
    end

    class CorporationWallet < Base
      self.scope = 'esi-wallet.read_corporation_wallet.v1'
      self.cache_duration = 120

      def initialize(corporation_id)
        @path = "/corporations/#{corporation_id}/wallets"
      end
    end

    class CorporationWallets < Base
      self.scope = 'esi-wallet.read_corporation_wallets.v1'
      self.cache_duration = 300
    end

    class Route < Base
      def initialize(origin_id, destination_id)
        @path = "/route/#{origin_id}/#{destination_id}"
      end
    end

    class MarketHistory < Base
      def initialize(region_id:, type_id:)
        @path = "/markets/#{region_id}/history"
        @params = { type_id: type_id }
      end
    end

    class MarketTypes < Base
      self.scope = nil
      self.cache_duration = 600

      def initialize(region_id:)
        @path = "/markets/#{region_id}/types"
        @paginated = true
      end
    end

    class MarketGroups < Base
      def initialize
        @path = '/markets/groups'
        @paginated = true
      end
    end

    class MarketGroup < Base
      def initialize(id)
        @path = "/markets/groups/#{id}"
      end
    end

    class MarketPrices < Base
      def initialize
        @path = '/markets/prices'
      end
    end

    class MarketOrders < Base
      def initialize(region_id:, type_id: nil)
        @path = "/markets/#{region_id}/orders"
        @params = { order_type: :all }
        @params[:type_id] = type_id if type_id.present?
        @paginated = type_id.blank?
      end
    end

    class Killmails < Base
      self.scope = 'esi-killmails.read_killmails.v1'

      def initialize(character_id:, max_count: 50, max_kill_id: nil)
        @path = "/characters/#{character_id}/killmails/recent"
        @params = { max_count: max_count }
        @params[:max_kill_id] = max_kill_id if max_kill_id
      end
    end

    class Killmail < Base
      def initialize(id:, hash:)
        @path = "killmails/#{id}/#{hash}"
      end
    end

    class Fleet < Base
      def initialize(fleet_id)
        @path = "fleets/#{fleet_id}"
      end
    end

    class FleetMembers < Base
      def initialize(fleet_id)
        @path = "fleets/#{fleet_id}/members"
      end
    end

    class FleetWings < Base
      def initialize(fleet_id)
        @path = "fleets/#{fleet_id}/wings"
      end
    end

    class Fittings < Base
      self.scope = 'esi-fittings.read_fittings.v1'

      def initialize(character_id)
        @path = "characters/#{character_id}/fittings"
      end
    end

    class DeleteFitting < Base
      def initialize(character_id, fitting_id)
        @path = "characters/#{character_id}/fittings/#{fitting_id}"
        @method = :delete
      end
    end

    class OpenMarketDetails < Base
      self.scope = 'esi-ui.open_window.v1'

      def initialize(type_id)
        @path = '/ui/openwindow/marketdetails'
        @method = :post
        @params = { type_id: type_id }
      end
    end
  end
end
