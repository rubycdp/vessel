# frozen_string_literal: true

require "addressable/uri"

module Vessel
  class Request
    attr_reader :url, :uri, :method, :data

    def self.build(*urls)
      urls.empty? ? [new] : urls.map { |url| new(url: url) }
    end

    def initialize(url: nil, method: :parse, data: nil)
      if url
        @url = url.to_s
        @uri = Addressable::URI.parse(@url)
      end

      @method = method
      @data = data.freeze if data
    end

    def stub?
      !url
    end
  end
end
