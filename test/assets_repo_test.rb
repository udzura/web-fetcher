require 'test_helper'

class WebFetcherAssetsRepoTest < Test::Unit::TestCase
  def setup
    @repo = WebFetcher::AssetRepo.new
  end

  def test_extract
    @repo.parse_body_and_extract_links!(content)
    assert_equal("/images/150709359.jpg", @repo.images[0])
    assert_equal("https://other.example.com/images/150709359-2.jpg", @repo.images[1])
  end

  def test_each_asset
    uri = URI.parse("https://dummy.example.com/foo/")
    @repo.instance_eval {
      @images = %w(/images/150709359.jpg ./images/150709359.jpg https://other.example.com/images/150709359-2.jpg)
    }

    dest = []
    @repo.each_assets(base_uri: uri) do |asset|
      dest << asset
    end

    assert_equal(
      URI.parse("https://dummy.example.com/images/150709359.jpg"),
      dest[0])
    assert_equal(
      URI.parse("https://dummy.example.com/foo/images/150709359.jpg"),
      dest[1])
    assert_equal(
      URI.parse("https://other.example.com/images/150709359-2.jpg"),
      dest[2])
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
      <img src="https://other.example.com/images/150709359-2.jpg" width='250' />
    </div>
  </body>
</html>
    CONTENT
  end
end
