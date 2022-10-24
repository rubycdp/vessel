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
      @delay, @headers = settings.values_at(:delay, :headers)
      @driver = Driver::Registry.instance.build(settings)
    end

    def post(*requests)
      requests.map do |request|
        Concurrent::Promises.future_on(pool, queue, request) { |q, r| q << driver.go_to(r) }
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
        min_threads: settings[:min_threads],
        max_threads: settings[:max_threads]
      )
    end
  end
end
