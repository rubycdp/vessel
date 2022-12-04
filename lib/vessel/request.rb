# frozen_string_literal: true

require "addressable/uri"

module Vessel
  class Request
    DEFAULT_HANDLER = :parse

    attr_reader :url, :handler, :data, :delay, :cookies, :headers, :once

    def initialize(url: nil, callback: nil, handler: nil, delay: 0, cookies: nil, headers: nil, data: nil, once: true)
      @url = Addressable::URI.parse(url) if url
      @delay = delay.is_a?(Range) ? rand(delay) : delay
      @cookies = cookies
      @headers = headers
      @handler = handler || callback || DEFAULT_HANDLER
      @data = deep_clone(data) || {}
      @once = once
    end

    alias callback handler

    def stub?
      !url
    end

    def to_handler
      { url: url, data: data, handler: handler }
    end

    def ==(other)
      url == other.url &&
        data == other.data &&
        handler == other.handler &&
        delay == other.delay &&
        cookies == other.cookies &&
        headers == other.headers &&
        once == other.once
    end

    private

    def deep_clone(value)
      case value
      when Hash
        value.inject({}) { |b, (k, v)| b.merge(k => deep_clone(v)) }
      when Array
        value.inject([]) { |b, v| b << deep_clone(v) }
      else
        value
      end
    end
  end
end
