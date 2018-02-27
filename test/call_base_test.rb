# frozen_string_literal: true

require 'test_helper'

def mock_base_call(opts = {})
  klass = Esi::Calls::Base.new
  klass.path = opts[:path]
  klass.params = opts[:params]
  klass
end

def actual_checksum(klass)
  return unless klass.respond_to? :cache_key
  klass.cache_key.split(':').last
end

class EsiCallBaseTest < EsiTest
  context "with path /mock_call/1234 and params { p2: 'val2', p1: 'val1' }" do
    setup do
      @first_call = mock_base_call(path: '/mock_call/1234', params: { p2: 'val2', p1: 'val1' })
    end

    should 'have an argument checksum of cfeaac873cdfaa73c441f0c9ead7ab75' do
      assert_equal 'cfeaac873cdfaa73c441f0c9ead7ab75', actual_checksum(@first_call)
    end

    context 'with a second call using the same path and same params in a different order' do
      setup do
        @second_call = mock_base_call(path: '/mock_call/1234', params: { p1: 'val1', p2: 'val2' })
      end

      should 'have the same checksum as the original call' do
        assert_equal actual_checksum(@first_call), actual_checksum(@second_call)
      end
    end

    context 'with a second call using same path and different params' do
      setup do
        @second_call = mock_base_call(path: '/mock_call/1234', params: { p1: 'val3', p2: 'val4' })
      end

      should 'not have the same checksum as the original call' do
        refute_equal actual_checksum(@first_call), actual_checksum(@second_call)
      end
    end

    context 'with a second call having a different path and same params' do
      setup do
        @second_call = mock_base_call(path: '/another_mock_call/1234', params: { p2: 'val2', p1: 'val1' })
      end

      should 'not have the same checksum as the original call' do
        refute_equal actual_checksum(@first_call), actual_checksum(@second_call)
      end
    end
  end

  context 'having an array as one of the param values' do
    setup do
      @first_call = mock_base_call(path: '/mock/1234', params: { p1: [1, 2, 3, 4] })
    end

    should 'have an argument checksum of cf8d74d3773bd0a9a325c94aa23e2a82' do
      assert_equal 'cf8d74d3773bd0a9a325c94aa23e2a82', actual_checksum(@first_call)
    end

    context 'with a second call using same path and same array in different order' do
      setup do
        @second_call = mock_base_call(path: '/mock/1234', params: { p1: [4, 3, 2, 1] })
      end

      should 'have the same checksum as the original call' do
        assert_equal actual_checksum(@first_call), actual_checksum(@second_call)
      end
    end
  end
end
