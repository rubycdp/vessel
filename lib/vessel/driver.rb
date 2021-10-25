# frozen_string_literal: true

require "vessel/driver/page"

module Vessel
  class Driver
    def self.driver_name(name)
      @@drivers ||= {}
      @@drivers[name.to_sym] = self
    end

    def self.build(settings = nil)
      name = settings[:driver_name].to_sym
      @@drivers.fetch(name.to_sym).new(settings)
    end

    require "vessel/driver/ferrum"
    require "vessel/driver/mechanize"

    attr_reader :browser, :settings

    def initialize(settings = nil)
      @settings = settings
      start(settings[:driver_options])
      at_exit { stop }
    end

    def start(**options)
      raise NotImplementedError
    end

    def stop
      raise NotImplementedError
    end

    def create_page
      raise NotImplementedError
    end

    def restart
      stop
      start
      true
    end
  end
end
