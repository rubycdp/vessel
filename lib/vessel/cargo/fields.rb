# frozen_string_literal: true

module Vessel
  class Cargo
    class Fields
      attr_reader :service

      def initialize(data = nil)
        @service = {}
        @fields = data.to_h || {}
      end

      def []=(key, value)
        @fields[key.to_sym] = value
      end

      def [](key)
        @fields[key.to_sym]
      end

      def values_at(*args)
        @fields.values_at(*args)
      end

      def count
        @fields.count
      end

      def select(&block)
        @fields.send(:select, &block)
      end

      def zip(value)
        @fields.zip(value)
      end

      def key?(value)
        @fields.key?(value)
      end

      def keys
        @fields.keys
      end

      def to_h
        @fields
      end

      def each(&block)
        @fields.each(&block)
      end
    end
  end
end
