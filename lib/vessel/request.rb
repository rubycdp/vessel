# frozen_string_literal: true

require "addressable/uri"

module Vessel
  class Request
    DEFAULT_HANDLER = :parse

    attr_reader :url, :uri, :handler, :data, :delay, :cookies, :headers


    def initialize(url: nil, handler: nil, delay: nil, cookies: nil, headers: nil, data: nil)
      if url
        @url = url.to_s
        @uri = Addressable::URI.parse(@url)
      end

      @delay, @cookies, @headers = delay, cookies, headers
      @handler = handler || DEFAULT_HANDLER
      @data = data.freeze if data
    end

    def stub?
      !url
    end
  end
end
