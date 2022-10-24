# frozen_string_literal: true

require "singleton"

module Vessel
  class Driver
    class Registry
      include Singleton

      attr_reader :drivers

      def initialize
        @drivers = {}
      end

      def register(name, klass)
        @drivers[name.to_sym] = klass
      end

      def build(settings = nil)
        name = settings[:driver_name].to_sym
        @drivers.fetch(name.to_sym).new(settings)
      end
    end
  end
end
