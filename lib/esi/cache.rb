require 'active_support/cache'

module Esi
  class Cache
    ESI_CACHE_NAMESPACE ||= 'esi:requests'.freeze
    ESI_CACHE_PATH ||= '/tmp/esi/requests'.freeze
    attr_reader :store

    def initialize
      args = [
        Esi.config.cache_store,
        cache_path,
        { namespace: Esi.config.cache_namespace || ESI_CACHE_NAMESPACE }
      ].compact
      @store = ActiveSupport::Cache.lookup_store(*args)
    end

    private

    def cache_path
      return unless Esi.config.cache_store == :file_store
      Esi.config.cache_path || ESI_CACHE_PATH
    end
  end
end
