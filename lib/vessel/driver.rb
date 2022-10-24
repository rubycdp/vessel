# frozen_string_literal: true

require "vessel/driver/page"
require "vessel/driver/registry"

module Vessel
  class Driver
    def self.driver_name(name)
      Registry.instance.register(name, self)
    end

    require "vessel/driver/ferrum/driver"
    require "vessel/driver/mechanize/driver"

    attr_reader :browser, :settings, :proxy

    def initialize(settings)
      @settings = settings
      @proxy = settings[:proxy].new if settings[:proxy] && settings[:proxy] <= Proxy
      start
      at_exit { stop }
    end

    def start
      raise NotImplementedError
    end

    def stop
      raise NotImplementedError
    end

    def create_page(proxy: nil)
      raise NotImplementedError
    end

    def restart
      stop
      start
      true
    end

    def go_to(request)
      return [nil, request] if request.stub?

      page = create_page(proxy: proxy&.next)
      page.blacklist = settings[:blacklist] if settings[:blacklist]
      page.whitelist = settings[:whitelist] if settings[:whitelist]
      page.headers = request.headers if request.headers
      page.cookies = request.cookies if request.cookies

      # Delay is set between requests when we don't want to bombard server with
      # requests so it requires crawler to be single threaded. Otherwise it doesn't
      # make sense.
      sleep(delay) if settings[:max_threads] == 1 && delay.positive?

      page.go_to(request.url)
      [page, request]
    rescue StandardError => e
      [page, request, e]
    end
  end
end
