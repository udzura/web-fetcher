# frozen_string_literal: true

require_relative "web_fetcher/version"
require 'uri'
require 'net/http'

module WebFetcher
  class Error < StandardError
  end

  class Client1
    def initialize
      @path_rule = lambda {|uri|
        "#{uri.host}.html"
      }
    end

    def process(target)
      content = get(target)
      dir = Dir.pwd
      output_to_file(content, dir, @path_rule.call(target))
    end

    private
    def get(target)
      res = Net::HTTP.start(target.host, target.port) do |http|
        path = if target.path.empty?
                 "/"
               else
                 target.path
               end
        http.get(path)
      end

      res.body
    end

    def output_to_file(content, dir, path)
      File.open(File.join(dir, path), 'w') do |f|
        f.write content
      end
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
    exit 10
  end
end