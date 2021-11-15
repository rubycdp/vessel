# frozen_string_literal: true

require "forwardable"
require "concurrent-ruby"

module Vessel
  class Scheduler
    extend Forwardable
    delegate %i[scheduled_task_count completed_task_count queue_length] => :pool

    attr_reader :driver, :queue, :delay, :headers, :settings

    def initialize(queue, settings)
      @queue = queue
      @settings = settings
      @min_threads, @max_threads, @delay, @headers =
        settings.values_at(:min_threads, :max_threads, :delay, :headers)
      @driver = Driver.build(settings)
    end

    def post(*requests)
      requests.map do |request|
        Concurrent::Promises.future_on(pool, queue, request) { |q, r| q << go_to(r) }
      end
    end

    def stop
      pool.shutdown
      pool.kill unless pool.wait_for_termination(30)
      driver.stop
    end

    private

    def pool
      @pool ||= Concurrent::ThreadPoolExecutor.new(
        max_queue: 0,
        min_threads: @min_threads,
        max_threads: @max_threads
      )
    end

    def go_to(request)
      return [nil, request] if request.stub?

      page = driver.create_page
      # page.proxy = settings[:proxy].call if settings[:proxy]
      page.blacklist = blacklist if settings[:blacklist]
      page.whitelist = whitelist if settings[:whitelist]
      page.headers = request.headers if request.headers
      page.cookies = request.cookies if request.cookies

      # Delay is set between requests when we don't want to bombard server with
      # requests so it requires crawler to be single threaded. Otherwise it doesn't
      # make sense.
      sleep(delay) if @max_threads == 1 && delay.positive?

      page.go_to(request.url)
      [page, request]
    rescue StandardError => e
      [page, request, e]
    end
  end
end
