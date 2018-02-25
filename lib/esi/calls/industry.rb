# frozen_string_literal: true

module Esi
  class Calls
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
  end
end
