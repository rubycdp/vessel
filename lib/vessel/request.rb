# frozen_string_literal: true

require "addressable/uri"

module Vessel
  class Request
    attr_reader :url, :uri, :method

    def self.build(*urls)
      urls.map { |url| new(url: url) }
    end

    def initialize(url:, method: :parse)
      @url = url.to_s
      @uri = Addressable::URI.parse(@url)
      @method = method
    end
  end
end
