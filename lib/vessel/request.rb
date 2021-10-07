# frozen_string_literal: true

require "addressable/uri"

module Vessel
  class Request
    DEFAULT_HANDLER = :parse

    attr_reader :url, :uri, :handler, :data

    def self.build(url_handlers)
      url_handlers.empty? ? [new] : url_handlers.map { |u, h| new(url: u, handler: h) }
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
