# frozen_string_literal: true

require "forwardable"

module Vessel
  class Driver
    module Mechanize
      class Page < Page
        extend Forwardable
        delegate %i[css at_css xpath at_xpath body] => :page

        attr_reader :mechanize

        def initialize(mechanize)
          super()
          @mechanize = mechanize
        end

        def close
          mechanize.shutdown
          @mechanize = nil
        end

        def go_to(url)
          mechanize.get(url)
        end

        def headers=(headers)
          mechanize.request_headers = headers
        end

        def headers
          mechanize.request_headers
        end

        def cookies=(cookies)
          cookies.each { |c| mechanize.cookie_jar << ::Mechanize::Cookie.new(c) }
        end

        def cookies
          mechanize.cookies
        end

        def status
          page.code.to_i
        end

        def size
          page.content.bytesize
        end

        def current_url
          page&.uri.to_s
        end

        # rubocop:disable all
        def blacklist=(*)
          @@_blacklist_warning ||= begin
            warn "blacklist is not supported by mechanize driver"
            true
          end
        end

        def whitelist=(*)
          @@_whitelist_warning ||= begin
            warn "whitelist is not supported by mechanize driver"
            true
          end
        end
        # rubocop:enable all

        private

        def page
          mechanize.current_page
        end
      end
    end
  end
end
