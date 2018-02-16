require 'test_helper'

class EsiCacheTest < EsiTest
  def test_null_cache
    Esi.config.cache = nil
    assert_instance_of ActiveSupport::Cache::NullStore, Esi.cache
  end

  # This should test that we don't create a new instance every time `Esi.cache` is called
  def test_null_cache_single_instance
    Esi.config.cache = nil
    assert_equal Esi.cache.object_id, Esi.cache.object_id
  end

  def test_default_cache
    assert_instance_of ActiveSupport::Cache::MemoryStore, Esi.cache
  end

  def test_custom_cache
    # cache = ActiveSupport::Cache::NullStore.new
    Esi.config.cache = cache = ActiveSupport::Cache::NullStore.new
    assert_equal cache.object_id, Esi.cache.object_id
  end
end
