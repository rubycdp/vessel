# frozen_string_literal: true

require "ferrum"
require "forwardable"

module Vessel
  class Cargo
    DELAY = 0
    START_URLS = {}.freeze
    MIDDLEWARE = [].freeze
    MIN_THREADS = 1
    MAX_THREADS = Concurrent.processor_count

    class << self
      attr_reader :settings

      def run(settings = nil, &block)
        self.settings.merge!(Hash(settings))
        Engine.run(self, &block)
      end

      def domain(name)
        settings[:domain] = name
      end

      def start_urls(*url_handlers)
        settings[:start_urls] = url_handlers.compact.flatten.inject({}) do |options, url_handler|
          options.merge(url_handler.is_a?(Hash) ? url_handler : { url_handler => Request::DEFAULT_HANDLER })
        end
      end

      def delay(value)
        settings[:delay] = value
      end

      def timeout(value)
        settings[:timeout] = value
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

      def ferrum(**options)
        settings[:ferrum] = options
      end

      def intercept(&block)
        settings[:intercept] = block
      end

      def settings
        @settings ||= {
          delay: DELAY,
          start_urls: START_URLS,
          middleware: MIDDLEWARE,
          min_threads: MIN_THREADS,
          max_threads: MAX_THREADS,
          ferrum: Hash.new,
          intercept: nil,
          headers: nil,
          domain: name&.split('::')&.last&.downcase
        }
      end
    end

    extend Forwardable
    delegate %i[at_css css at_xpath xpath] => :page

    attr_reader :page

    def initialize(page = nil)
      @page = page
    end

    def domain
      self.class.settings[:domain]
    end

    def parse
      raise NotImplementedError
    end

    private

    def request(**options)
      Request.new(**options)
    end

    def absolute_url(relative)
      Addressable::URI.join(page.current_url, relative).to_s
    end

    def current_url
      Addressable::URI.parse(page.current_url)
    end
  end
end
