# frozen_string_literal: true

require "ferrum"

module Vessel
  class Driver
    module Ferrum
      class Driver < ::Vessel::Driver
        DEFAULT_OPTIONS = {
          timeout: 60,
          js_errors: false,
          process_timeout: 30,
          pending_connection_errors: false,
          # proxy: { server: true },
          browser_options: { "ignore-certificate-errors" => nil }
        }.freeze

        driver_name :ferrum

        def start(**options)
          options = DEFAULT_OPTIONS.merge(options)
          @browser = ::Ferrum::Browser.new(**options)
        end

        def stop
          browser&.quit
          @browser = nil
        end

        def create_page
          Page.new(browser)
        end
      end
    end
  end
end
