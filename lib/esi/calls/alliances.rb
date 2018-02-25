# frozen_string_literal: true

module Esi
  class Calls
    class Alliances < Base
      self.cache_duration = 3600

      def initialize
        @path = '/alliances'
      end
    end

    class AllianceNames < Base
      self.cache_duration = 3600

      def initialize(alliance_ids)
        @path = '/alliances/names'
        @params = { alliance_ids: alliance_ids.join(',') }
      end
    end

    class Alliance < Base
      self.cache_duration = 3600

      def initialize(alliance_id)
        @path = "/alliances/#{alliance_id}"
      end
    end
  end
end
