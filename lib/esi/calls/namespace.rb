module Esi
  module Calls
    class Namespace
      attr_accessor :client

      def initialize(client)
        @client = client
        @calls = self.class.constants
      end

      def method_missing(name, *args, &block)
        klass = nil
        begin
          klass = self.class.const_get(Esi.classify(name).to_sym)
        rescue NameError
          super(name, *args, &block)
        end

        client.execute(klass.new(*args), &block)
      end
    end
  end
end
