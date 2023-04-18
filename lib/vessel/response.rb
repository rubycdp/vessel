# frozen_string_literal: true

require "forwardable"
require "nokogiri"
require "addressable/uri"

module Vessel
  class Response
    extend Forwardable

    attr_accessor :rejected
    attr_reader :url, :data, :handler, :page, :attempt, :cookies

    delegate %i[xpath css at_xpath at_css] => :page_or_body

    def initialize(handler:, url: nil, data: nil, page: nil, attempt: 1)
      @url = Addressable::URI.parse(url) if url
      @data = data
      @handler = handler
      @attempt = attempt
      @driven_page = page
      @page = @driven_page&.page
      @rejected = false
      @cookies = @driven_page&.cookies&.map do |c|
        {
          name: c.name, value: c.value, domain: c.domain, path: c.path,
          httponly: c.httponly?, secure: c.secure?, expires: c.expires
        }
      end
    end

    alias callback handler

    def absolute_url(relative, encode: true)
      if encode
        relative = url_decode(relative)
        relative = url_encode(relative)
      end
      join_url(url.to_s, relative)
    end

    def join_url(head, tail)
      Addressable::URI.join(head, tail).to_s
    end

    def url_encode(uri)
      Addressable::URI.encode(uri)
    end
    alias uri_encode url_encode

    def url_decode(uri)
      Addressable::URI.unencode(uri)
    end
    alias uri_decode url_decode

    def body
      @body ||= Nokogiri::HTML(raw)
    end

    def raw
      @raw ||= @driven_page&.body
    end

    def sync_body(seconds = 2)
      sleep(seconds)
      @raw = @body = nil
      body
    end

    def close
      @driven_page&.close
      @driven_page = @page = nil
    end

    def stub?
      !url
    end

    def status
      @driven_page&.status
    end

    def headers
      @driven_page&.headers
    end

    def size
      @driven_page&.size
    end

    def ==(other)
      url == other.url &&
        data == other.data &&
        handler == other.handler &&
        page == other.page &&
        attempt == other.attempt &&
        cookies == other.cookies
    end

    private

    def page_or_body
      Vessel.page_snapshot ? body : page
    end
  end
end
