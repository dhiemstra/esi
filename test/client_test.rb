# frozen_string_literal: true

require 'test_helper'

class EsiClientTest < MiniTest::Test
  context 'With predefined client' do
    setup do
      @client = Esi::Client.new
      Thread.current[:esi_client] = @client
    end
    teardown do
      Thread.current[:esi_client] = nil
    end

    describe '#current=' do
      should 'override predefined client' do
        new_client = Esi::Client.new
        Esi::Client.current = new_client
        assert_equal new_client, Thread.current[:esi_client]
        refute_equal @client, Thread.current[:esi_client]
      end
    end

    describe '#current' do
      should 'return current client' do
        assert_equal @client, Esi::Client.current
      end
    end

    describe '#switch_to_default' do
      should 'return new instance of client' do
        Esi::Client.switch_to_default
        refute_equal @client, Thread.current[:esi_client]
        assert_instance_of Esi::Client, Thread.current[:esi_client]
      end
    end

    describe '.switch_to' do
      should 'switch to new instance of client' do
        new_client = Esi::Client.new
        new_client.switch_to
        assert_equal new_client, Esi::Client.current
      end
    end

    describe '.with_client' do
      should 'yield block with_client' do
        new_client = Esi::Client.new
        new_client.with_client do
          assert_equal new_client, Esi::Client.current
        end
      end

      should 'revert to previous client after yield' do
        new_client = Esi::Client.new
        new_client.with_client do
          assert_equal new_client, Esi::Client.current
        end
        assert_equal @client, Esi::Client.current
      end
    end
  end

  context 'Without predefined client' do
    setup do
      Thread.current[:esi_client] = nil
    end
    teardown do
      Thread.current[:esi_client] = nil
    end

    describe '#current=' do
      should 'set current client' do
        assert_nil Thread.current[:esi_client]
        client = Esi::Client.new
        Esi::Client.current = client
        assert_equal client, Thread.current[:esi_client]
      end
    end

    describe '#current' do
      should 'return a new instance of client' do
        refute_nil Esi::Client.current
        assert_instance_of Esi::Client, Esi::Client.current
      end
    end

    describe '#switch_to_default' do
      should 'return new instance of client' do
        Esi::Client.switch_to_default
        assert_instance_of Esi::Client, Thread.current[:esi_client]
      end
    end

    describe '.switch_to' do
      should 'switch to new instance of client' do
        new_client = Esi::Client.new
        new_client.switch_to
        assert_equal new_client, Esi::Client.current
      end
    end

    describe '.with_client' do
      should 'yield block with_client' do
        new_client = Esi::Client.new
        new_client.with_client do
          assert_equal new_client, Esi::Client.current
        end
      end

      should 'revert to default client after yield' do
        new_client = Esi::Client.new
        new_client.with_client do
          assert_equal new_client, Esi::Client.current
        end
        refute_equal new_client, Esi::Client.current
        assert_instance_of Esi::Client, Esi::Client.current
      end
    end
  end
end
