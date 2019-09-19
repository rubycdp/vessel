require "thor"
require "pp"

module Vessel
  class CLI < Thor
    desc "version", "Print version."
    def version
      puts Vessel::VERSION
    end

    desc "start NAME", "Start crawling given name."
    def start(name)
      crawler = find_crawler(name)
      engine = Engine.new(crawler)
      engine.start
    end
  end
end
