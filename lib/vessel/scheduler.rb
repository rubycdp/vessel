# frozen_string_literal: true

require "forwardable"
require "concurrent-ruby"

module Vessel
  class Scheduler
    extend Forwardable
    delegate %i[scheduled_task_count completed_task_count queue_length] => :pool

    attr_reader :driver, :queue, :settings

    def initialize(queue, settings)
      @queue = queue
      @settings = settings
      @driver = Driver::Registry.instance.build(settings)
    end

    def post(*requests)
      requests.flatten.map do |request|
        Concurrent::Future.execute(executor: pool,
                                   args: [request]) { |r| queue << driver.go_to(r) }
      end
    end

    def stop
      pool.shutdown
      pool.kill unless pool.wait_for_termination(30)
      driver.stop
    end

    def force_kill
      pool.send(:ns_kill_execution)
      driver.stop
    end

    def idle?
      queue_length.zero? && scheduled_task_count == completed_task_count
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
