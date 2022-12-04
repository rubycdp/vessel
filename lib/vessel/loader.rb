# frozen_string_literal: true

module Vessel
  class Loader
    attr_reader :crawlers

    def initialize
      @crawlers = {}
    end

    def templator
      Templator
    end

    def load_crawlers
      Dir["crawlers/**/*.rb"].sort.each { |file| require(file) }
    end

    def load_crawler(name)
      path = File.expand_path("crawlers/#{name}.rb")
      require(path) if File.exist?(path)
    end

    def register(name, klass)
      @crawlers.merge!(name => klass)
    end

    def find_crawler(name)
      @crawlers[name]
    end

    def list_crawlers
      @crawlers.keys.sort
    end
  end
end
