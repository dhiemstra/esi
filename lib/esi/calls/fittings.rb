# frozen_string_literal: true

module Esi
  class Calls
    class Fittings < Base
      self.scope = 'esi-fittings.read_fittings.v1'

      def initialize(character_id)
        @path = "/characters/#{character_id}/fittings"
      end
    end

    class DeleteFitting < Base
      def initialize(character_id, fitting_id)
        @path = "characters/#{character_id}/fittings/#{fitting_id}"
        @method = :delete
      end
    end
  end
end
