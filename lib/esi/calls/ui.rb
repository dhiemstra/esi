module Esi
  module Calls
    class Ui < Namespace
      # Link: https://esi.tech.ccp.is/latest/#!/User32Interface/post_ui_openwindow_marketdetails
      # Scope: esi-ui.open_window.v1
      # Cache: none
      class OpenMarketDetails < Base
        def initialize(type_id)
          @path = "/ui/openwindow/marketdetails"
          @method = :post
          @params = { type_id: type_id }
        end
      end
    end
  end
end
