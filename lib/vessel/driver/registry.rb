# frozen_string_literal: true

require "singleton"

module Vessel
  class Driver
    class Registry
      include Singleton

      BUILTIN = {
        ferrum: { path: "vessel/driver/ferrum/driver", gem: "ferrum" },
        mechanize: { path: "vessel/driver/mechanize/driver", gem: "mechanize" }
      }.freeze

      attr_reader :drivers

      def initialize
        @drivers = {}
      end

      # Registers a driver class under a name.
      #
      # @param name [Symbol, String] the name used in the `driver` setting
      # @param klass [Class] a {Vessel::Driver} subclass
      # @return [Class] the registered class
      def register(name, klass)
        @drivers[name.to_sym] = klass
      end

      # Looks a driver up by name, loading the built-in one on demand.
      #
      # @param name [Symbol, String] the name used in the `driver` setting
      # @return [Class] a {Vessel::Driver} subclass
      # @raise [Vessel::DriverNotFoundError] when the driver or its gem is missing
      def fetch(name)
        name = name.to_sym
        @drivers[name] || load_builtin(name)
      end

      # Builds a driver instance out of the crawler settings.
      #
      # @param settings [Hash, nil] the crawler settings
      # @return [Vessel::Driver] the driver instance
      def build(settings = nil)
        fetch(settings[:driver_name]).new(settings)
      end

      private

      def load_builtin(name)
        builtin = BUILTIN[name]
        raise DriverNotFoundError, "Driver #{name.inspect} is not registered" unless builtin

        begin
          require builtin[:path]
        rescue LoadError => e
          raise DriverNotFoundError, "Driver #{name.inspect} needs the #{builtin[:gem]} gem, " \
                                     "add `gem \"#{builtin[:gem]}\"` to your Gemfile (#{e.message})"
        end

        @drivers.fetch(name)
      end
    end
  end
end
