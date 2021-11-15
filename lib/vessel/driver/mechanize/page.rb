# frozen_string_literal: true

require "forwardable"
require "mechanize"

module Vessel
  class Driver
    module Mechanize
      class Page < Page
        extend Forwardable
        delegate %i[css at_css xpath at_xpath body] => :page

        def create
          @browser = ::Mechanize.new
        end

        def close
          browser.shutdown
          @browser = nil
        end

        def go_to(url)
          browser.get(url)
        end

        def page
          browser.current_page
        end

        def current_url
          page&.uri.to_s
        end

        def proxy=(host:, port:, user: nil, password: nil)
          # browser.set_proxy(host, port, user, password)
        end

        def blacklist=(*); end

        def headers=(headers)
          browser.request_headers = headers
        end

        def headers
          browser.request_headers
        end

        def cookies=(cookies)
          cookies.each { |c| browser.cookie_jar << Mechanize::Cookie.new(c) }
        end

        def cookies
          browser.cookies
        end

        def status
          page.code
        end

        def size
          page.content.bytesize
        end
      end
    end
  end
end
