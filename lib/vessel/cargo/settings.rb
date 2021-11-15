# frozen_string_literal: true

module Vessel
  class Cargo
    module Settings
      def domain(name)
        settings[:domain] = name
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

      def threads(min: MIN_THREADS, max: MAX_THREADS)
        settings[:min_threads] = min
        settings[:max_threads] = max
      end

      def middleware(*classes)
        settings[:middleware] = classes
      end

      # def proxy(callable)
      #   settings[:proxy] = callable
      # end

      def settings
        @settings ||= {
          delay: DELAY,
          start_urls: START_URLS,
          middleware: MIDDLEWARE,
          min_threads: MIN_THREADS,
          max_threads: MAX_THREADS,
          driver_name: :ferrum,
          driver_options: {},
          headers: nil,
          # proxy: nil,
          domain: name&.split("::")&.last&.downcase
        }
      end
    end
  end
end
