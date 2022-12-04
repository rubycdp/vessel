# frozen_string_literal: true

require "mechanize"
require "vessel/driver/mechanize/page"

module Vessel
  class Driver
    module Mechanize
      class Driver < ::Vessel::Driver
        def self.indirect_network_errors
          @indirect_network_errors ||= (super + [::Mechanize::ResponseCodeError]).freeze
        end

        driver_name :mechanize

        def start
          # Nothing to start here
        end

        def stop
          # Nothing to stop here
        end

        def create_page(proxy: nil)
          mechanize = ::Mechanize.new do |m|
            m.user_agent = settings.dig(:headers, "User-Agent")
            m.set_proxy(proxy[:host], proxy[:port], proxy[:user], proxy[:password]) if proxy
          end

          Page.new(mechanize)
        end
      end
    end
  end
end
