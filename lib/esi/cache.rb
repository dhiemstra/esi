require 'active_support/cache'

module Esi
  class Cache
    ESI_CACHE_NAMESPACE ||= 'esi:requests'.freeze
    ESI_CACHE_PATH ||= '/tmp/esi/requests'.freeze
    attr_reader :store

    def initialize
      cache_path = Esi.config.cache_store == :file_store ? (Esi.config.cache_path || ESI_CACHE_PATH) : nil
      @store = ActiveSupport::Cache.lookup_store(
        Esi.config.cache_store,
        cache_path,
        namespace: Esi.config.cache_namespace || ESI_CACHE_NAMESPACE
      )
    end
  end
end
