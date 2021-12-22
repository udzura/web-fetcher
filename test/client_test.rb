require 'test_helper'
require 'fileutils'

class WebFetcherClientTest < Test::Unit::TestCase
  def setup
    @path = '/tmp/foo'
    FileUtils.mkdir_p '/tmp/foo'

    @client = WebFetcher::Client1.new
  end

  def teardown
    FileUtils.remove_entry_secure '/tmp/foo'
  end

  def test_output_to_file
    # FIXME: this is private method test
    content = "Hello, world"
    dir = @path
    path = 'dummy.com.html'

    @client.send :output_to_file, content, dir, path

    assert File.file?("/tmp/foo/dummy.com.html")
    assert_equal "Hello, world", File.read("/tmp/foo/dummy.com.html")
  end
end
