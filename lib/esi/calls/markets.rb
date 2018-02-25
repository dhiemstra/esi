# frozen_string_literal: true

module Esi
  class Calls
    class StructureOrders < Base
      def initialize(structure_id:)
        @path = "/markets/structures/#{structure_id}"
        @paginated = true
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
  end
end
