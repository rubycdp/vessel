# frozen_string_literal: true

require "forwardable"

module Vessel
  class Driver
    module Ferrum
      class Page < Page
        extend Forwardable
        delegate %i[css at_css xpath at_xpath body current_url go_to] => :page

        attr_reader :page

        def initialize(page)
          super()
          @page = page
        end

        def close
          page.context.dispose if page.use_proxy?
          page.close
        end

        def headers=(headers)
          return unless headers

          page.headers.set(headers)
        end

        def headers
          page.headers.get
        end

        def cookies=(cookies)
          cookies.each { |c| page.cookies.set(c) }
        end

        def cookies
          page.cookies.all.values
        end

        def status
          page.network.status
        end

        def size
          page.network.traffic.map do |req|
            [req.response&.body_size, req.response&.headers_size]
          end.flatten.compact.inject(&:+)
        end

        def blacklist=(patterns)
          page.network.blacklist = patterns
        end

        def whitelist=(patterns)
          page.network.whitelist = patterns
        end
      end
    end
  end
end
