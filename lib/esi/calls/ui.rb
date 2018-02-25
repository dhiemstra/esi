# frozen_string_literal: true

module Esi
  class Calls
    class OpenMarketDetails < Base
      self.scope = 'esi-ui.open_window.v1'

      def initialize(type_id)
        @path = '/ui/openwindow/marketdetails'
        @method = :post
        @params = { type_id: type_id }
      end
    end
  end
end
