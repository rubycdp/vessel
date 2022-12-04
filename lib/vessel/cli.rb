# frozen_string_literal: true

require "thor"

module Vessel
  class CLI < Thor
    desc "version", "Print version."
    def version
      puts Vessel::VERSION
    end

    desc "list", "List all available crawlers of current project."
    def list
      Vessel.boot
      Vessel.loader.load_crawlers
      puts Vessel.loader.list_crawlers
    end

    desc "settings NAME", "Get the settings for given name."
    def settings(name)
      crawler = find_crawler(name)
      settings = crawler.settings
      puts "Delay: #{settings[:delay]}"
      puts "Allow cookies: #{settings[:allow_cookies]}"
      puts "Cookies: #{settings[:cookies]}"
      puts "Middleware: #{settings[:middleware]}"
      puts "Start urls:\n"
      PP.pp(settings[:start_urls])
    end

    desc "start NAME", "Start crawling given name."
    def start(name)
      crawler = find_crawler(name)
      engine = Engine.new(crawler)
      engine.run
    end

    desc "parse NAME URL CALLBACK --data=key:value", "Parse given url and call a callback with response."
    method_option :data, type: :hash, default: {}, required: false
    def parse(name, url, callback)
      crawler = find_crawler(name)
      engine = Engine.new(crawler)
      data = options[:data].transform_keys(&:to_sym)
      engine.parse(url, callback, data)
    end

    desc "new NAME", "Generate new project."
    def new(name)
      templates = File.expand_path("skeleton", __dir__)
      FileUtils.cp_r(templates, "./#{name}")
      puts "Project #{name} generated"
    end

    desc "generate NAME OPTIONS", "Generate crawler skeleton with given name and parameters."
    def generate(name, *options)
      require "erb"
      Vessel.boot
      templator = Vessel.loader.templator
      templator.new(name, options).build
    end

    private

    def find_crawler(name)
      Vessel.boot
      Vessel.loader.load_crawler(name)
      crawler = Vessel.loader.find_crawler(name)
      abort "Crawler not found" unless crawler
      crawler
    end
  end
end
