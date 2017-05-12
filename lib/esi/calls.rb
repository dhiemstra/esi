module Esi
  module Calls
    autoload :Base, 'esi/calls/base'
    autoload :Namespace, 'esi/calls/namespace'
    autoload :Ui, 'esi/calls/ui'
    autoload :Universe, 'esi/calls/universe'

    # class Namespace
    #   def self.method_missing(name, *args, &block)
    #     class_name = name.to_s.split('_').map(&:capitalize).join
    #     puts "Namespace called for #{name}"
    #     puts "const_get: #{const_defined?(class_name)}"
    #
    #     if const_defined?(class_name)
    #       klass = const_get(class_name)
    #       call = klass.new(*args)
    #       call.paginated? ? request_paginated(call, &block) : request(call, &block)
    #     else
    #       super
    #     end
    #   end
    # end

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

    # Link: https://esi.tech.ccp.is/latest/#!/Wallet/get_characters_character_id_wallets
    # Scope: esi-wallet.read_character_wallet.v1
    # Cache: 2 minutes
    class CharacterWallets < Base
      def initialize(character_id)
        @path = "/characters/#{character_id}/wallets"
      end
    end

    # Link: https://esi.tech.ccp.is/latest/#!/Character/get_characters_character_id_blueprints
    # Scope: esi-characters.read_blueprints.v1
    # Cache: 1 hour
    class CharacterBlueprints < Base
      def initialize(character_id)
        @path = "/characters/#{character_id}/wallets"
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
  end
end
