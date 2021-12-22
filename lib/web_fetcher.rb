# frozen_string_literal: true

require_relative "web_fetcher/version"
require 'uri'
require 'net/http'
require 'nokogiri'

module WebFetcher
  class Error < StandardError
  end

  class Client1
    def initialize(show_metadata: false, download_assets: false)
      @show_metadata = show_metadata
      @download_assets = download_assets
      @path_rule = lambda {|uri|
        "#{uri.host}.html"
      }
      @metadata = nil
      @dir = ENV['WEB_FETCHER_DEST_DIR'] || Dir.pwd
    end

    def process(target)
      @metadata = Metadata.new(target)

      @metadata.set_last_fetch!(@dir, @path_rule.call(target))

      content = get(target)
      @metadata.parse_body_and_set_metadata!(content)

      if @show_metadata
        print_metadata @metadata
      end

      output_to_file(content, @dir, @path_rule.call(target))

      if @download_assets
        require 'fileutils'
        dest = File.join(@dir, '_assets', @metadata.site)
        FileUtils.mkdir_p dest

        repo = AssetRepo.new
        repo.parse_body_and_extract_links!(content)
        repo.each_assets(base_uri: target) do |uri|
          download_asset(uri, dest: dest)
        end
      end
    end

    private
    def get(target)
      http = Net::HTTP.new(target.host, target.port)
      if target.scheme == 'https'
        http.use_ssl = true
      end

      path = if target.path.empty?
               "/"
             else
               target.path
             end
      res = http.get(path)

      res.body
    end

    def download_asset(target, dest:)
      content = get(target)
      output_to_file(content, dest, File.basename(target.path))
    end

    def output_to_file(content, dir, path)
      File.open(File.join(dir, path), 'w') do |f|
        f.write content
      end
    end

    def print_metadata(metadata)
      puts <<~DATA
        site: #{metadata.site}
        num_links: #{metadata.num_links}
        images: #{metadata.images}
        last_fetch: #{metadata.last_fetch || "<not yet>"}
      DATA
    end
  end

  class Metadata
    def initialize(uri)
      @site = uri.host
      @num_links = 0
      @images = 0
    end
    attr_reader :site, :num_links, :images, :last_fetch

    def set_last_fetch!(dir, filepath)
      fullpath = File.join(dir, filepath)
      if File.exist?(fullpath)
        @last_fetch = File.stat(fullpath).mtime
      else
        @last_fetch = nil
      end
    end

    def parse_body_and_set_metadata!(body)
      doc = Nokogiri::HTML body
      @num_links = doc.css('a').size
      @images = doc.css('img').size
    rescue => e
      # if failed ro parse XML, fallback to regex...
      # but TBA
    end
  end

  class AssetRepo
    def initialize
      @images = []
      @stylesheets = []
      @javascripts = []
    end
    attr_reader :images, :stylesheets, :javascripts

    def parse_body_and_extract_links!(body)
      # TODO: dry
      doc = Nokogiri::HTML body

      @images = doc.css('img').to_a.map{|e| e.attr(:src)}
    end

    def each_assets(base_uri:, &blk)
      [*images, *stylesheets, *javascripts].each do |path|
        uri = case path
              # scheme
              when /\A([a-zA-Z0-9]+):\/\//
                # using $1 is a bit hacky
                schema = $1
                if ['http', 'https'].include?(schema)
                  URI.parse(path)
                else
                  raise "Unsupported schema: #{schema}"
                end
              # absolute / relative path can be handled by URI#merge!
              else
                base_uri.merge(path)
              end
        blk.call(uri)
      end
    end
  end

  def self.main1
    args = []
    show_metadata = false
    download_assets = false

    ARGV.each do |arg|
      case arg
      when'--metadata'
        show_metadata = true
      when'--download-assets'
        download_assets = true
      else
        args << arg
      end
    end

    client = Client1.new(show_metadata: show_metadata, download_assets: download_assets)

    args.each do |uri|
      target = URI.parse(uri)
      client.process(target)
    end
  rescue => e
    $stderr.puts "Error: #{e.inspect}"
    raise e
    exit 10
  end
end
