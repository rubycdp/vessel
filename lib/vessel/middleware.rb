# frozen_string_literal: true

require "concurrent"
require "forwardable"

module Vessel
  class Middleware
    class InvalidItemError < RuntimeError; end

    class << self
      extend Forwardable
      delegate %i[scheduled_task_count completed_task_count queue_length] => :pool

      def build(settings, &block)
        @settings = settings
        @middlewares = if block_given?
                         [block]
                       else
                         settings[:middleware].map { |m| Object.const_get(m).new(settings) }
                       end
        self
      end

      def call(fields)
        Concurrent::Future.execute(executor: pool) do
          @middlewares.inject(fields.to_h) { |hash, middleware| middleware.call(hash, fields) }
        end
      end

      def pool
        @pool ||= Concurrent::ThreadPoolExecutor.new(
          min_threads: @settings[:min_threads],
          max_threads: @settings[:max_threads],
          max_queue: 0
        )
      end

      def idle?(after: false)
        completed_tasks = completed_task_count + (after ? 1 : 0)
        queue_length.zero? && scheduled_task_count == completed_tasks
      end

      def stop
        pool.shutdown
        pool.kill unless pool.wait_for_termination(30)
      end

      def force_kill
        pool.send(:ns_kill_execution)
      end
    end

    attr_reader :settings

    def initialize(settings)
      @settings = settings
    end

    def call
      raise NotImplementedError
    end

    def ==(other)
      self.class == other.class
    end
  end
end
