# frozen_string_literal: true

module Esi
  class Calls
    class DogmaAttributes < Base
      def initialize
        @path = '/dogma/attributes/'
      end
    end

    class DogmaAttribute < Base
      def initialize(attribute_id)
        @path = "/dogma/attributes/#{attribute_id}"
      end
    end

    class DogmaEffects < Base
      def initialize
        @path = '/dogma/effects/'
      end
    end

    class DogmaEffect < Base
      def initialize(effect_id)
        @path = "/dogma/effects/#{effect_id}"
      end
    end
  end
end
