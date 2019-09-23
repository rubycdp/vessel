# frozen_string_literal: true

require "forwardable"
require "concurrent-ruby"

module Vessel
  class Scheduler
    extend Forwardable
    delegate %i[scheduled_task_count completed_task_count queue_length] => :@pool

    attr_reader :browser, :queue, :delay

    def initialize(queue, settings)
      @queue = queue
      @min_threads, @max_threads, @delay =
        settings.values_at(:min_threads, :max_threads, :delay)

      options = {}
      options.merge!(timeout: settings[:timeout]) if settings[:timeout]
      @browser = Ferrum::Browser.new(**options)
    end

    def post(*requests)
      requests.map do |request|
        Concurrent::Promises.future_on(pool, queue, request) do |queue, request|
          queue << goto(request)
        end
      end
    end

    private

    def pool
      @pool ||= Concurrent::ThreadPoolExecutor.new(
        max_queue: 0,
        min_threads: @min_threads,
        max_threads: @max_threads
      )
    end

    def goto(request)
      page = browser.create_page
      sleep(delay) if @max_threads == 1 && delay > 0
      page.goto(request.url)
      [page, request]
    rescue => e
      e
    end
  end
end
