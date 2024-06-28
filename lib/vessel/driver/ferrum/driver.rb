# frozen_string_literal: true

require "ferrum"
require "vessel/driver/ferrum/page"

module Vessel
  class Driver
    module Ferrum
      class Driver < ::Vessel::Driver
        DEFAULT_OPTIONS = {
          timeout: 60,
          js_errors: false,
          process_timeout: 30,
          pending_connection_errors: false,
          browser_options: { "ignore-certificate-errors" => nil }
        }.freeze

        def self.direct_network_errors
          @direct_network_errors ||= (super + [::Ferrum::TimeoutError, ::Ferrum::StatusError]).freeze
        end

        driver_name :ferrum

        def start
          driver_options = settings.fetch(:driver_options, {})
          @browser = ::Ferrum::Browser.new(**DEFAULT_OPTIONS.merge(driver_options))
        end

        def stop
          browser&.quit
          @browser = nil
        end

        def create_page(proxy: nil)
          options = {}
          options.merge!(proxy: proxy) if proxy
          page = browser.create_page(**options)
          Page.new(page, context: browser.contexts[page.context_id])
        end
      end
    end
  end
end
