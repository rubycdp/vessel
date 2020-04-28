# frozen_string_literal: true

require "ferrum"
require "forwardable"

module Vessel
  class Cargo
    DELAY = 0
    START_URLS = [].freeze
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

      def start_urls(*urls)
        settings[:start_urls] = urls
      end

      def delay(value)
        settings[:delay] = value
      end

      def timeout(value)
        settings[:timeout] = value
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

      def settings
        @settings ||= {
          delay: DELAY,
          middleware: MIDDLEWARE,
          start_urls: START_URLS,
          min_threads: MIN_THREADS,
          max_threads: MAX_THREADS,
          ferrum: Hash.new,
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
  end
end
