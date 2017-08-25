module Esi
  module Calls
    class Character < Namespace
      class Location < Base
        self.scope = 'esi-location.read_location.v1'
        self.cache_duration = 5

        def initialize(character_id)
          @path = "/characters/#{character_id}/location"
        end
      end
    end
  end
end
