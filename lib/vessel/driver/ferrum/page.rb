# frozen_string_literal: true

require "forwardable"

module Vessel
  class Driver
    module Ferrum
      class Page < Page
        extend Forwardable
        delegate %i[css at_css xpath at_xpath body current_url go close] => :page

        def create
          @page = browser.create_page
        end

        def proxy=(host:, port:, user: nil, password: nil)
          # browser.proxy_server.rotate(host: host, port: port, user: user, password: password)
        end

        def blacklist=(patterns)
          page.network.blacklist = patterns
        end

        def headers=(headers)
          return unless headers

          page.headers.set(headers)
        end

        def headers
          page.headers.get
        end

        def cookies=(cookies)
          cookies.each { |c| page.cookies.set(c.dup) }
        end

        def cookies
          page.cookies.all
        end

        def status
          page.network.status
        end

        def size
          page.network.traffic.map { |req|
            [req.response&.body_size, req.response&.headers_size]
          }.flatten.compact.inject(&:+)
        end
      end
    end
  end
end
