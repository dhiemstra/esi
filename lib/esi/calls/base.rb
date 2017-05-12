module Esi
  module Calls
    class Base
      attr_accessor :client, :path, :params

      def method
        @method ||= :get
      end

      def url
        Esi.generate_url(path, params)
      end

      def page=(page)
        self.params ||= {}
        self.params[:page] = page
      end

      def paginated?
        !!@paginated
      end
    end
  end
end
