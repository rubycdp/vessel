# frozen_string_literal: true

module Vessel
  class Proxy
    attr_reader :proxies

    def next
      @index ||= 0
      @prepared ||= prepare
      return if proxies.nil? || proxies.empty?

      settings = proxies[@index % proxies.size]
      @index += 1
      settings
    end

    def prepare
      raise NotImplementedError
    end
  end

  class RoundRobinProxy < Proxy
    PROXIES = [].freeze

    def initialize
      @proxies = self.class::PROXIES
      super
    end

    def prepare
      true
    end
  end

  class ShuffledProxy < RoundRobinProxy
    def prepare
      @proxies = @proxies.shuffle
      true
    end
  end
end
