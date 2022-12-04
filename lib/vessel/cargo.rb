# frozen_string_literal: true

require "forwardable"
require "vessel/cargo/fieldable"
require "vessel/cargo/settings"
require "vessel/cargo/callbacks"

module Vessel
  class Cargo
    def self.run(settings = nil, &block)
      self.settings.merge!(Hash(settings))
      Engine.run(self, &block)
    end

    def self.build_request(url:, **options)
      Request.new(url: url,
                  delay: settings[:delay],
                  cookies: settings[:cookies],
                  headers: settings[:headers],
                  **options)
    end

    def self.start_requests
      return build_request(url: nil) if settings[:start_urls].empty?

      settings[:start_urls].map { |u, h| build_request(url: u, handler: h) }
    end

    def self.store_cookies(cookies)
      settings[:cookies] = cookies
    end

    include Callbacks
    include Fieldable
    extend Settings
    extend Forwardable
    delegate %i[at_css css at_xpath xpath absolute_url join_url
                url url_encode url_decode uri_encode uri_decode
                data attempt body raw] => :response

    attr_reader :settings, :domain, :response, :page, :size

    def initialize(response = nil)
      @settings = self.class.settings
      @domain = settings[:domain]
      @response = response
      @page = response&.page
      @size = response&.size
    end

    def parse
      raise NotImplementedError
    end

    private

    def request(url:, encode: true, **options)
      url = absolute_url(url, encode: encode)
      self.class.build_request(url: url, **options)
    end
  end

  Crawler = Cargo
end
