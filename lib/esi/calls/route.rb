# frozen_string_literal: true

module Esi
  class Calls
    class Route < Base
      def initialize(origin_id, destination_id)
        @path = "/route/#{origin_id}/#{destination_id}"
      end
    end
  end
end
