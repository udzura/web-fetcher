# frozen_string_literal: true

require_relative "web_fetcher/version"
require 'uri'
require 'net/http'
require 'nokogiri'

module WebFetcher
  class Error < StandardError
  end

  class Client1
    def initialize(show_metadata: false)
      @show_metadata = show_metadata
      @path_rule = lambda {|uri|
        "#{uri.host}.html"
      }
      @metadata = nil
    end

    def process(target)
      @metadata = Metadata.new(target)
      dir = ENV['WEB_FETCHER_DEST_DIR'] || Dir.pwd

      @metadata.set_last_fetch!(dir, @path_rule.call(target))

      content = get(target)
      @metadata.parse_body_and_set_metadata!(content)

      if @show_metadata
        print_metadata @metadata
      end

      output_to_file(content, dir, @path_rule.call(target))
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

  def self.main1
    args = []
    show_metadata = false
    ARGV.each do |arg|
      if arg == '--metadata'
        show_metadata = true
      else
        args << arg
      end
    end

    client = Client1.new(show_metadata: show_metadata)

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
