# frozen_string_literal: true

require "forwardable"
require "concurrent-ruby"

module Vessel
  class Scheduler
    extend Forwardable
    delegate %i[scheduled_task_count completed_task_count queue_length] => :@executor

    def initialize(queue, settings)
      delay = settings[:delay]
      min_threads = settings[:min_threads]
      @max_threads = settings[:max_threads]
      @queue, @delay = queue, delay
      @executor = Concurrent::ThreadPoolExecutor.new(
        max_queue: 0,
        min_threads: min_threads,
        max_threads: @max_threads
      )
    end

    def post(*requests)
      requests.map { |r| future(r) }
    end

    private

    def future(request)
      Concurrent::Promises.future_on(@executor, @queue, request) do |queue, request|
        begin
          puts "request start #{request.url}"
          browser = Ferrum::Browser.new
          sleep(@delay) if @max_threads == 1 && @delay > 0
          browser.goto(request.url)
          puts "request   end #{request.url}"
          queue << [browser, request]
        rescue => e
          queue << e
        end
      end
    end
  end
end
