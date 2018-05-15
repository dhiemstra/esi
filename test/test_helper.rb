# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter do |source_file|
    source_file.lines.count < 5
  end
  add_filter '/spec/'
end

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
