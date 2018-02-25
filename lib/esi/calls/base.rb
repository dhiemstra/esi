# frozen_string_literal: true

module Esi
  class Calls
    # Base parent class used for all API calls. Provides basic functionality and state for caching
    # and request initialization
    class Base
      CACHE_NAMESPACE = 'esi'

      class_attribute :scope
      class_attribute :cache_duration

      attr_accessor :path, :params

      # Returns an unique key based on the endpoint and params which is used for caching
      #
      # @return [String] cache key
      def cache_key
        @cache_key ||= begin
          cache_args = [CACHE_NAMESPACE, path.gsub(%r{^\/}, ''), params.sort].flatten
          ActiveSupport::Cache.expand_cache_key(cache_args)
        end
      end

      # Returns the request HTTP method to use
      # @return [Symbol] request method
      def method
        @method ||= :get
      end

      # Returns the generated endpoint URL including any parameters
      # @return [String] request URI
      def url
        Esi.generate_url(path, params)
      end

      # @param page [Integer] page number
      def page=(page)
        self.params ||= {}
        self.params[:page] = page
      end

      # Returns whether the endpoint supports pagination
      # @return [Boolean]
      def paginated?
        !@paginated
      end
    end
  end
end
