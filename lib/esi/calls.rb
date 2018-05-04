# frozen_string_literal: true

require 'esi/calls/base'
require 'esi/calls/info'

require 'esi/calls/alliances'
require 'esi/calls/characters'
require 'esi/calls/corporations'
require 'esi/calls/dogma'
require 'esi/calls/fittings'
require 'esi/calls/fleets'
require 'esi/calls/industry'
require 'esi/calls/killmails'
require 'esi/calls/markets'
require 'esi/calls/route'
require 'esi/calls/search'
require 'esi/calls/sovereignty'
require 'esi/calls/ui'
require 'esi/calls/universe'

module Esi
  class Calls
    class << self
      # Generate a list with all available calls
      #
      # @return [Array<Symbol>] list of underscored call names
      def list
        @list ||= constants.select { |c| Esi::Calls.const_get(c).try(:scope) }
                           .map { |c| c.to_s.underscore.to_sym }
      end
    end
  end
end
