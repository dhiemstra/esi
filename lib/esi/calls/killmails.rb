# frozen_string_literal: true

module Esi
  class Calls
    # TODO: Rename to `CharacterKillmails`?
    class Killmails < Base
      self.scope = 'esi-killmails.read_killmails.v1'

      def initialize(character_id:, max_count: 50, max_kill_id: nil)
        @path = "/characters/#{character_id}/killmails/recent"
        @params = { max_count: max_count }
        @params[:max_kill_id] = max_kill_id if max_kill_id
      end
    end

    class Killmail < Base
      def initialize(id:, hash:)
        @path = "/killmails/#{id}/#{hash}"
      end
    end
  end
end
