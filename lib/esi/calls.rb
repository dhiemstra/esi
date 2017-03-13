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

    class Character < Base
      def initialize(character_id)
        @path = "/characters/#{character_id}"
      end
    end

    class Regions < Base
      def initialize(region_id=nil)
        raise 'NOT IMPLEMENTED YET'
        @path = "/regions/#{region_id}"
      end
    end

    class Structures < Base
      def initialize
        @path = "/universe/structures/"
      end
    end

    class Structure < Base
      def initialize(structure_id)
        @path = "/universe/structures/#{structure_id}"
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
  end
end
