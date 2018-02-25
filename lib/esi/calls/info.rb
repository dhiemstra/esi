# frozen_string_literal: true

module Esi
  class Calls
    class Info
      attr_reader :name, :call
      delegate :scope, :cache_duration, to: :call

      def initialize(name)
        @name = name.to_sym
        @call = Calls.const_get(name.to_s.camelize)
      end

      def to_s
        @name.to_s
      end

      def character?
        name.to_s.starts_with?('character')
      end

      def corporation?
        name.to_s.starts_with?('corporat')
      end
    end
  end
end
