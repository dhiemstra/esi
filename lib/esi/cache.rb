require 'active_support/cache'

module Esi
  class Cache
    ESI_CACHE_NAMESPACE ||= 'esi:requests'.freeze
    attr_reader :store

    def initialize
      @store = ActiveSupport::Cache.lookup_store(
        Esi.config.cache_store,
        namespace: Esi.config.cache_namespace || ESI_CACHE_NAMESPACE
      )
    end
  end
end
