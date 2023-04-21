# frozen_string_literal: true

require "vessel/engine/stats"

module Vessel
  class Engine
    include Stats

    def self.run(*args, &block)
      new(*args, &block).tap(&:run)
    end

    attr_reader :crawler_class, :settings, :scheduler, :middleware_scheduler

    def initialize(klass, &block)
      @crawler_class = klass
      @settings = klass.settings
      @queue = SizedQueue.new(settings[:max_threads])
      @scheduler = Scheduler.new(@queue, settings)
      @middleware_scheduler = MiddlewareScheduler.new(settings, &block)
    end

    def run
      at_exit do
        crawler_class.new.info(stats)
        crawler_class.new.before_stop
      end

      trap_sigint
      crawler_class.new.before_start
      crawler_class.new.before(stats)
      Concurrent::TimerTask.execute(execution_interval: crawler_class::INFO_INTERVAL) { crawler_class.new.info(stats) }
      schedule(crawler_class.start_requests)
      event_loop
    ensure
      scheduler.stop
      middleware_scheduler.stop
      crawler_class.new.after(stats)
    end

    def parse(url, handler, data = nil)
      trap_sigint
      request = crawler_class.build_request(url: url, handler: handler, data: data)
      schedule(request)
      event_loop
    ensure
      scheduler.stop
      middleware_scheduler.stop
    end

    def handle(response, request, error)
      increase(:res_dequeued)
      return if response.rejected

      crawler = crawler_class.new(response)
      crawler_class.store_cookies(response.cookies) if settings[:allow_cookies]
      args = error ? [:on_error, request, error] : [request.handler].compact
      Logger.debug("Engine: crawler starts processing #{response.url} with :#{response.handler}")
      crawler.send(*args) do |*result|
        result = result.flatten
        if result.all? { |i| i.is_a?(Request) }
          Logger.debug("Engine: :#{response.handler} enqueued requests #{result.map { |r| r.url.to_s }}")
          schedule(result)
        else
          result.each { |fields| process(fields) }
        end
      end
      Logger.debug("Engine: crawler stopped processing #{response.url}")
    rescue StandardError => e
      Logger.error("Engine: there was an issue while processing #{response.url}")
      Logger.error("Engine: `#{e.class}: #{e.message}`\n#{e.backtrace.join("\n")}")
    ensure
      increase(:res_handled)
      response.close
    end

    private

    def engine_idle?
      @queue.empty? &&
        req_enqueued.value == res_dequeued.value &&
        res_dequeued.value == res_handled.value &&
        item_pipelined.value == item_processed.value &&
        item_processed.value == (item_sent.value + item_rejected.value)
    end

    def engine_and_scheduler_idle?
      engine_idle? && @scheduler.idle?
    end

    def idle?
      engine_and_scheduler_idle? && middleware_scheduler.idle?
    end

    def schedule(*requests)
      requests.size.times { increase(:req_enqueued) }
      scheduler.post(*requests)
    end

    def process(fields)
      increase(:item_pipelined)
      middleware_scheduler&.call(fields)&.add_observer(self, :on_item_processed)
    end

    def on_item_processed(_time, value, error)
      increase(:item_processed)
      increase(:item_sent) if value && !error
      increase(:item_rejected) if error

      if error && !error.is_a?(Middleware::InvalidItemError)
        Logger.error("Engine: issue `#{error.class}: #{error.message}` raised in the middleware")
        Logger.error("Engine: \n#{error.backtrace.join("\n")}")
      end

      @queue.close if engine_and_scheduler_idle? && middleware_scheduler.idle?(after: true)
    end

    def trap_sigint
      trap "SIGINT" do
        puts "\n\nEngine: terminating...\n\n"
        @queue.clear
        @queue.close
        scheduler.force_kill
        middleware_scheduler.force_kill
      end
    end

    def event_loop
      until @queue.closed?
        message = @queue.pop
        break unless message

        response, request, error = message
        handle(response, request, error)
        @queue.close if idle?
      end
    end
  end
end
