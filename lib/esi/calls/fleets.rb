# frozen_string_literal: true

module Esi
  class Calls
    class Fleet < Base
      def initialize(fleet_id)
        @path = "/fleets/#{fleet_id}"
      end
    end

    class FleetMembers < Base
      def initialize(fleet_id)
        @path = "/fleets/#{fleet_id}/members"
      end
    end

    class FleetWings < Base
      def initialize(fleet_id)
        @path = "/fleets/#{fleet_id}/wings"
      end
    end
  end
end
