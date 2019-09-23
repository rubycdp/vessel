# frozen_string_literal: true

require "concurrent-ruby"

module Vessel
  module Settings
    DELAY = 0
    START_URLS = [].freeze
    MIDDLEWARE = [].freeze
    MIN_THREADS = 1
    MAX_THREADS = Concurrent.processor_count

    attr_reader :settings

    def domain(name)
      settings[:domain] = name
    end

    def start_urls(*urls)
      settings[:start_urls] = urls
    end

    # Delay is set between requests when we don't want to bombard server with
    # requests so it requires crawler to be single threaded. Otherwise doesn't
    # make sense.
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

    def settings
      @settings ||= {
        delay: DELAY,
        middleware: MIDDLEWARE,
        start_urls: START_URLS,
        min_threads: MIN_THREADS,
        max_threads: MAX_THREADS,
        domain: name&.split('::')&.last&.downcase
      }
    end
  end
end
