# frozen_string_literal: true

require 'test_helper'

Esi::Calls::MockCall = Class.new(Esi::Calls::Base) do
  def initialize
    self.path = '/mock_call/1234'
    self.params = { p2: 'val2', p1: 'val1' }
  end
end

class EsiCallBaseTest < EsiTest
  def test_cache_key
    assert_equal 'esi/mock_call/1234/p1/val1/p2/val2', Esi::Calls::MockCall.new.cache_key
  end
end
