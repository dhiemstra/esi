module Esi
  module Calls
    class Universe < Namespace
      # Link: https://esi.tech.ccp.is/latest/#!/Universe/get_universe_structures
      # Scope: none
      # Cache: 1 hour
      class Structures < Base
        def initialize
          @path = "/universe/structures"
        end
      end

      # Link: https://esi.tech.ccp.is/latest/#!/Universe/get_universe_structures_structure_id
      # Scope: none
      # Cache: 1 hour
      class Structure < Base
        def initialize(structure_id)
          @path = "/universe/structures/#{structure_id}"
        end
      end
    end
  end
end
