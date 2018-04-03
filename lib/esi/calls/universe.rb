# frozen_string_literal: true

module Esi
  class Calls
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

    class SystemKills < Base
      def initialize
        @path = '/universe/system_kills/'
      end
    end

    class SystemJumps < Base
      def initialize
        @path = '/universe/system_jumps/'
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
  end
end
