# frozen_string_literal: true

module Vessel
  class Middleware
    attr_reader :middleware

    def self.build(*classes)
      classes.inject { |base, klass| base.new(klass.new) }
    end

    def initialize(middleware = nil)
      @middleware = middleware
    end

    def ==(other)
      self.class == other.class
    end

    def call
      raise NotImplementedError
    end
  end
end
