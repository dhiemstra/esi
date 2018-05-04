# frozen_string_literal: true

module Esi
  class Calls
    class SovereigntyCampaigns < Base
      self.cache_duration = 5

      def initialize
        @path = '/sovereignty/campaigns'
      end
    end

    class SovereigntyMap < Base
      self.cache_duration = 5

      def initialize
        @path = '/sovereignty/map'
      end
    end

    class SovereigntyStructures < Base
      self.cache_duration = 120

      def initialize
        @path = '/sovereignty/structures'
      end
    end
  end
end
