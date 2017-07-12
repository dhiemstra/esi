module Esi
  class Calls
    class Base
      attr_accessor :path, :params

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
        !!@paginated
      end
    end

    class OpenMarketDetails < Base
      def initialize(type_id)
        @path = "/ui/openwindow/marketdetails"
        @method = :post
        @params = { type_id: type_id }
      end
    end

    class SolarSystem < Base
      def initialize(system_id)
        @path = "/universe/systems/#{system_id}"
      end
    end

    class Types < Base
      def initialize
        @path = "/universe/types"
        @paginated = true
      end
    end

    class Type < Base
      def initialize(type_id)
        @path = "/universe/types/#{type_id}"
      end
    end

    class Search < Base
      def initialize(character_id: nil, categories:, search:, strict: false)
        @path = (character_id ? "/characters/#{character_id}" : '') + "/search"
        @params = { categories: categories, search: search, strict: strict }
      end
    end

    class Characters < Base
      def initialize(character_ids)
        @path = "/characters/names"
        @params = { character_ids: character_ids.join(',') }
      end
    end

    class CharacterNames < Base
      def initialize(character_ids)
        @path = "/characters/names"
        @params = { character_ids: character_ids.join(',') }
      end
    end

    # Link: https://esi.tech.ccp.is/latest/#!/Character/get_characters_character_id
    # Cache: 1 hour
    class Character < Base
      def initialize(character_id)
        @path = "/characters/#{character_id}"
      end
    end

    # Link: https://esi.tech.ccp.is/dev/#!/Wallet/get_characters_character_id_wallet
    # Scope: esi-wallet.read_character_wallet.v1
    # Cache: 2 minutes
    class CharacterWallet < Base
      def initialize(character_id)
        @path = "/characters/#{character_id}/wallet"
      end
    end

    # Link: https://esi.tech.ccp.is/dev/#!/Wallet/get_characters_character_id_wallet_journal
    # Scope: esi-wallet.read_character_wallet.v1
    # Cache: 1 hour
    class CharacterWalletJournal < Base
      def initialize(character_id)
        @path = "/characters/#{character_id}/wallet/journal"
      end
    end

    # Link: https://esi.tech.ccp.is/dev/#!/Wallet/get_characters_character_id_wallet_transactions
    # Scope: esi-wallet.read_character_wallet.v1
    # Cache: 1 hour
    class CharacterWalletTransactions < Base
      def initialize(character_id)
        @path = "/characters/#{character_id}/wallet/transactions"
      end
    end

    # Link: https://esi.tech.ccp.is/latest/#!/Market/get_characters_character_id_orders
    # Scope: esi-markets.read_character_orders.v1
    # Cache: 1 hour
    class CharacterOrders < Base
      def initialize(character_id)
        @path = "/characters/#{character_id}/orders"
      end
    end

    # Link: https://esi.tech.ccp.is/latest/#!/Industry/get_characters_character_id_industry_jobs
    # Scope: esi-industry.read_character_jobs.v1
    # Cache: 5 minutes
    class CharacterIndustryJobs < Base
      def initialize(character_id, with_completed: false)
        @path = "/characters/#{character_id}/industry/jobs"
        @params = { with_completed: with_completed }
      end
    end

    # Link: https://esi.tech.ccp.is/dev/?datasource=tranquility#!/Contacts/get_characters_character_id_contacts
    # Scope: esi-contracts.read_character_contracts.v1
    # Cache: 1 hour
    class CharacterContracts < Base
      def initialize(character_id)
        @path = "/characters/#{character_id}/contracts"
      end
    end

    # Link: https://esi.tech.ccp.is/dev/#!/Location/get_characters_character_id_location
    # Scope: esi-location.read_location.v1
    # Cache: 1 hour
    class CharacterLocation < Base
      def initialize(character_id)
        @path = "/characters/#{character_id}/location"
      end
    end

    # Link: https://esi.tech.ccp.is/dev/#!/Contracts/get_characters_character_id_contracts_contract_id_items
    # Scope: esi-contracts.read_character_contracts.v1
    # Cache: 1 hour
    class ContractItems < Base
      def initialize(character_id, contract_id)
        @path = "/characters/#{character_id}/contracts/#{contract_id}/items"
      end
    end

    # Link: https://esi.tech.ccp.is/dev/#!/Location/get_characters_character_id_location
    # Scope: esi-location.read_location.v1
    # Cache: 5 seconds
    class CharacterLocation < Base
      def initialize(character_id)
        @path = "/characters/#{character_id}/location"
      end
    end

    class Alliances < Base
      def initialize
        @path = "/alliances"
      end
    end

    class AllianceNames < Base
      def initialize(alliance_ids)
        @path = "/alliances/names"
        @params = { alliance_ids: alliance_ids.join(',') }
      end
    end

    class Alliance < Base
      def initialize(alliance_id)
        @path = "/alliances/#{alliance_id}"
      end
    end

    class CorporationNames < Base
      def initialize(corporation_ids)
        @path = "/corporations/names"
        @params = { corporation_ids: corporation_ids.join(',') }
      end
    end

    class Corporation < Base
      def initialize(corporation_id)
        @path = "/corporations/#{corporation_id}"
      end
    end

    class CorporationStructures < Base
      def initialize(corporation_id)
        @path = "/corporations/#{corporation_id}/structures"
      end
    end

    class CorporationStructure < Base
      def initialize(corporation_id, structure_id)
        @path = "/corporations/#{corporation_id}/structures/#{structure_id}"
      end
    end

    # Link: https://esi.tech.ccp.is/dev/#!/Corporation/get_corporations_corporation_id_members
    # Scope: esi-corporations.read_corporation_membership.v1
    # Cache: 1 hour
    class CorporationMembers < Base
      def initialize(corporation_id)
        @path = "/corporations/#{corporation_id}/members"
      end
    end

    # Link: https://esi.tech.ccp.is/dev/#!/Corporation/get_corporations_corporation_id_roles
    # Scope: esi-corporations.read_corporation_membership.v1
    # Cache: 1 hour
    class CorporationRoles < Base
      def initialize(corporation_id)
        @path = "/corporations/#{corporation_id}/roles"
      end
    end

    class Structures < Base
      def initialize
        @path = "/universe/structures"
      end
    end

    class Structure < Base
      def initialize(structure_id)
        @path = "/universe/structures/#{structure_id}"
      end
    end

    class Route < Base
      def initialize(origin_id, destination_id)
        @path = "/route/#{origin_id}/#{destination_id}"
      end
    end

    class MarketGroups < Base
      def initialize
        @path = "/markets/groups"
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
        @path = "/markets/prices"
      end
    end

    class MarketOrders < Base
      def initialize(type_id: nil, structure_id: nil, region_id: Region::FORGE)
        @path = "/markets/structures/#{structure_id}"
        @path = "/markets/#{region_id}/orders"
        @params = { order_type: :all }
        @params[:type_id] = type_id if type_id.present?
        @paginated = type_id.blank?
      end
    end

    class StructureOrders < Base
      def initialize(structure_id:)
        @path = "/markets/structures/#{structure_id}"
        @paginated = true
      end
    end

    class MarketHistory < Base
      def initialize(type_id:, region_id: Region::FORGE)
        @path = "/markets/#{region_id}/history"
        @params = { type_id: type_id }
      end
    end

    class Killmails < Base
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
  end
end
