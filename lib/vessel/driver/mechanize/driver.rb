# frozen_string_literal: true

module Vessel
  class Driver
    module Mechanize
      class Driver < ::Vessel::Driver
        DEFAULT_OPTIONS = {}.freeze

        driver_name :mechanize

        def start(**options)
          @options = DEFAULT_OPTIONS.merge(options)
          @browser = ::Mechanize.new do |b|
            b.user_agent = settings.dig(:headers, "User-Agent")
          end
        end

        def stop
          browser&.shutdown
          @browser = nil
        end

        def create_page
          Page.new(browser)
        end
      end
    end
  end
end
