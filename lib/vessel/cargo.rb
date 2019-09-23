# frozen_string_literal: true

require "ferrum"
require "forwardable"

module Vessel
  class Cargo
    extend Settings

    def self.run(&block)
      Engine.run(self, &block)
    end

    attr_reader :domain, :page

    extend Forwardable
    delegate %i[at_css css at_xpath xpath] => :page

    def initialize(domain, page)
      @domain = domain
      @page = page
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
