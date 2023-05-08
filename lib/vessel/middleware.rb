# frozen_string_literal: true

module Vessel
  class Middleware
    class InvalidItemError < RuntimeError; end

    attr_reader :settings

    def initialize(settings)
      @settings = settings
    end

    def call
      raise NotImplementedError
    end

    def ==(other)
      self.class == other.class
    end
  end
end
