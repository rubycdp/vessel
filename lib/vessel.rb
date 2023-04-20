# frozen_string_literal: true

module Vessel
  class Error < StandardError; end

  class NotImplementedError < Error; end

  class << self
    attr_writer :loader, :page_snapshot

    def boot
      require File.expand_path("config/boot")
    end

    def env
      ENV.fetch("VESSEL_ENV", "dev")
    end

    def page_snapshot
      !!@page_snapshot
    end

    def loader
      @loader ||= Loader.new
    end
  end
end

require "concurrent-ruby"
require "vessel/cli"
require "vessel/engine"
require "vessel/middleware"
require "vessel/middleware_scheduler"
require "vessel/scheduler"
require "vessel/request"
require "vessel/response"
require "vessel/version"
require "vessel/cargo"
require "vessel/driver"
require "vessel/driver/ferrum/driver"
require "vessel/driver/mechanize/driver"
require "vessel/templator"
require "vessel/loader"
require "vessel/logger"
