module Esi
  module Calls
    class Namespace
      class << self
        def method_missing(name, *args, &block)
          klass = const_get(name.to_s.split('_').map(&:capitalize).join)
          klass.new(*args)
          # call.paginated? ? request_paginated(call, &block) : request(call, &block)
        rescue NameError
          super(name, *args, &block)
        end
      end
    end
  end
end
