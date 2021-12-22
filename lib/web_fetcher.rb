# frozen_string_literal: true

require_relative "web_fetcher/version"
require 'uri'
require 'net/http'
require 'nokogiri'

module WebFetcher
  class Error < StandardError
  end

  class Client1
    def initialize
      @path_rule = lambda {|uri|
        "#{uri.host}.html"
      }
      @metadata = nil
    end

    def process(target)
      @metadata = Metadata.new(target)
      @metadata.set_last_fetch!(@path_rule.call(target))

      content = get(target)
      @metadata.parse_body_and_set_metadata!(content)

      print_metadata @metadata

      dir = Dir.pwd
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

    def set_last_fetch!(filepath)
      if File.exist?(filepath)
        @last_fetch = File.stat(filepath).mtime
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
    args = ARGV.dup
    client = Client1.new

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
