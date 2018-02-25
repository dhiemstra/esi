# frozen_string_literal: true

module Esi
  class Calls
    class Search < Base
      self.scope = nil

      def initialize(character_id: nil, categories:, search:, strict: false)
        @path = (character_id ? "/characters/#{character_id}" : '') + '/search'
        @params = { categories: categories, search: search, strict: strict }
      end
    end
  end
end
