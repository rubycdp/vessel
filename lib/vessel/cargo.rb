# frozen_string_literal: true

require "ferrum"
require "forwardable"

module Vessel
  class Cargo
    extend Settings

    def self.run(settings, &block)
      self.settings.merge!(settings)
      Engine.run(self, &block)
    end

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
      Request.new(**options)
    end
  end
end
