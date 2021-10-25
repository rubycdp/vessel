# frozen_string_literal: true

require "thor"

module Vessel
  class CLI < Thor
    desc "version", "Print version."
    def version
      puts Vessel::VERSION
    end

    desc "start NAME", "Run given crawler."
    def start(name)
      raise NotImplementedError
    end
  end
end
