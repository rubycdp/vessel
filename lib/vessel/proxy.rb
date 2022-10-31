# frozen_string_literal: true

module Vessel
  class Proxy
    attr_reader :proxies

    def next
      @index ||= 0
      return unless proxies

      settings = proxies[@index % proxies.size]
      @index += 1
      settings
    end
  end

  class RoundRobinProxy < Proxy
    PROXIES = [].freeze

    def initialize
      super
      @proxies = self.class::PROXIES
    end
  end

  class ShuffledProxy < RoundRobinProxy
    def initialize
      super
      @proxies = self.class::PROXIES.shuffle
    end
  end
end
