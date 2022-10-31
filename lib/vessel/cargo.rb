# frozen_string_literal: true

require "forwardable"
require "vessel/cargo/settings"

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

    extend Settings
    extend Forwardable
    delegate %i[at_css css at_xpath xpath] => :page

    attr_reader :page

    def initialize(page = nil)
      @page = page
    end

    def domain
      self.class.settings[:domain]
    end

    def parse
      raise NotImplementedError
    end

    private

    def request(**options)
      self.class.build_request(**options)
    end

    def absolute_url(relative)
      Addressable::URI.join(page.current_url, relative).to_s
    end

    def current_url
      Addressable::URI.parse(page.current_url)
    end
  end

  Crawler = Cargo
end
