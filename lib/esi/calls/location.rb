# frozen_string_literal: true

module Esi
  class Calls
    # Get the character's online status
    # @see https://esi.evetech.net/ui/#/Location/get_characters_character_id_online
    #
    # @param [Integer] character id to fetch the data from
    #
    # @return [Hash]
    #   * :online [Boolean] If the character is online
    #   * :last_login [String, nil] Timestamp of the last login
    #   * :last_logout [String, nil] Timestamp of the last logout
    #   * :logins [Integer, nil] Total number of times the character has logged in
    class CharacterOnline < Base
      self.scope = 'esi-location.read_online.v1'
      self.cache_duration = 60

      def initialize(character_id)
        @path = "/characters/#{character_id}/online"
      end
    end

    # Get the character's current location
    # @see https://esi.evetech.net/ui/#/Location/get_characters_character_id_location
    #
    # @param [Integer] character id to fetch the data from
    #
    # @return [Hash]
    #   * :solar_system_id [Integer]
    #   * :station_id [Integer, nil]
    #   * :structure_id [Integer, nil]
    class CharacterLocation < Base
      self.scope = 'esi-location.read_location.v1'
      self.cache_duration = 5

      def initialize(character_id)
        @path = "/characters/#{character_id}/location"
      end
    end

    # Get the character's active ship
    # @see https://esi.evetech.net/ui/#/Location/get_characters_character_id_ship
    #
    # @param [Integer] character id to fetch the data from
    #
    # @return [Hash]
    #   * :ship_item_id [Integer]
    #   * :ship_type_id [Integer]
    #   * :ship_name [String]
    class CharacterShip < Base
      self.scope = 'esi-location.read_ship_type.v1'
      self.cache_duration = 5

      def initialize(character_id)
        @path = "/characters/#{character_id}/ship"
      end
    end
  end
end
