require 'test_helper'

Esi::Calls::MockCall = Class.new(Esi::Calls::Base) do
  def initialize
    self.params = {id: 1234}
  end
end

class EsiCallBaseTest < EsiTest
  def test_instance_name
    assert_equal :mock_call, Esi::Calls::MockCall.new.name
  end

  def test_cache_key
    assert_equal 'esi/mock_call/id/1234', Esi::Calls::MockCall.new.cache_key
  end
end
