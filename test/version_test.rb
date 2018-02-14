require 'test_helper'

class EsiVersionTest < EsiTest
  def test_that_it_has_a_version_number
    refute_nil ::Esi::VERSION
  end
end
