# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'esi'
require 'shoulda'
require 'minitest/autorun'

class EsiTest < Minitest::Test
  def teardown
    super

    # Reset config options to defaults after each test
    Esi.config = OpenStruct.new(Esi::DEFAULT_CONFIG)
  end
end
