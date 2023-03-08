# frozen_string_literal: true

require "vessel/proxy"
require "vessel/util"

module Vessel
  class Cargo
    module Settings
      include Vessel::Util

      DELAY = 0
      START_URLS = {}.freeze
      MIDDLEWARE = [].freeze
      MIN_THREADS = 1
      MAX_THREADS = Concurrent.processor_count
      NETWORK_ERROR_ATTEMPTS = 5

      def name
        settings[:domain]
      end

      def domain(value)
        settings[:domain] = value
        Vessel.loader.register(name, self)
      end

      def start_urls(*url_handlers)
        settings[:start_urls] = url_handlers.compact.flatten.inject({}) do |options, url_handler|
          options.merge(url_handler.is_a?(Hash) ? url_handler : { url_handler => Request::DEFAULT_HANDLER })
        end
      end

      def driver(name, **options)
        settings[:driver_name] = name.to_sym
        settings[:driver_options] = options
      end

      def delay(value)
        settings[:delay] = value
      end

      def headers(value)
        settings[:headers] = value
      end

      def cookie(name:, value:, domain: nil, path: nil, httponly: nil, secure: nil, expires: nil)
        settings[:cookies] ||= []
        domain ||= settings[:domain]
        cookie = { name: name, value: value, domain: domain, path: path,
                   httponly: httponly, secure: secure, expires: expires }.compact
        settings[:cookies] << cookie
      end

      def cookies(*value)
        value.flatten.each { |c| cookie(**c) }
      end

      def threads(min: MIN_THREADS, max: MAX_THREADS)
        settings[:min_threads] = min
        settings[:max_threads] = max
      end

      def middleware(*classes)
        settings[:middleware] = classes
      end

      def proxy(klass)
        settings[:proxy] = klass
      end

      def blacklist(patterns)
        settings[:blacklist] = patterns
      end

      def whitelist(patterns)
        settings[:whitelist] = patterns
      end

      def network_error_attempts(value)
        settings[:network_error_attempts] = value.to_i
      end

      def allow_cookies(value)
        settings[:allow_cookies] = value
      end

      def settings
        @settings ||= if superclass.respond_to?(:settings)
                        deep_clone(superclass.settings)
                      else
                        {
                          delay: DELAY, start_urls: START_URLS, middleware: MIDDLEWARE,
                          min_threads: MIN_THREADS, max_threads: MAX_THREADS,
                          driver_name: :ferrum, driver_options: {}, headers: nil,
                          cookies: nil, allow_cookies: true, proxy: nil,
                          blacklist: nil, whitelist: nil, domain: nil,
                          network_error_attempts: NETWORK_ERROR_ATTEMPTS
                        }
                      end
      end

      def to_domain_name(klass)
        # name&.split("::")&.last&.downcase
        klass.name.gsub(/[a-zA-Z](?=[A-Z])/, '\0 ').downcase.split.map do |value|
          next "." if value == "dot"
          next "-" if value == "dash"

          value
        end.join
      end
    end
  end
end
