require 'test_helper'

class WebFetcherSmokeTest < Test::Unit::TestCase
  def test_version
    assert_equal("1.0.0", WebFetcher::VERSION)
  end
end
