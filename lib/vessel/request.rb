# frozen_string_literal: true

require "addressable/uri"

module Vessel
  class Request
    DEFAULT_HANDLER = :parse

    attr_reader :url, :uri, :handler, :data

    def self.build(handlers)
      handlers.empty? ? [new] : handlers.map { |url, handler| new(url: url, handler: handler) }
    end

    def initialize(url: nil, handler: DEFAULT_HANDLER, data: nil)
      if url
        @url = url.to_s
        @uri = Addressable::URI.parse(@url)
      end

      @handler = handler
      @data = data.freeze if data
    end

    def stub?
      !url
    end
  end
end
