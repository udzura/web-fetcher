require 'test_helper'
require 'fileutils'

class WebFetcherMetadataTest < Test::Unit::TestCase
  def setup
    @path = '/tmp/foo2'
    FileUtils.mkdir_p '/tmp/foo2'
    @now = Time.now
    FileUtils.touch '/tmp/foo2/dummy.example.com.html', mtime: @now
  end

  def teardown
    FileUtils.remove_entry_secure '/tmp/foo2'
  end

  def test_attributes
    uri = URI.parse("https://dummy.example.com")
    @metadata = WebFetcher::Metadata.new uri

    @metadata.set_last_fetch!(@path, 'dummy.example.com.html')
    @metadata.parse_body_and_set_metadata!(content)

    assert_equal("dummy.example.com", @metadata.site)
    assert_equal(3, @metadata.num_links)
    assert_equal(2, @metadata.images)
    assert_equal(@now, @metadata.last_fetch)
  end

  def content
    <<~CONTENT
<html lang="ja">
  <head>
    <meta charset="utf-8">
    <title>udzura.jp - Home</title>
  </head>
  <body onload="sh_highlightDocument();">
    <div id="main">
      <h1>My profile</h1>
      <img src="/images/150709359.jpg" width='250' />
      <h2>My dog</h2>
      <img src="/images/150709359-2.jpg" width='250' />
      <ul>
        <li><a href="/webservices/1/" title="2012-08-06 17:35 updated">
          Dummy</a></li>
        <li><a href="/webservices/2/" title="2012-08-06 17:35 updated">
          Dummy</a></li>
        <li><a href="/webservices/3/" title="2012-08-06 17:35 updated">
          Dummy</a></li>
      </ul>
    </div>
  </body>
</html>
    CONTENT
  end
end
