# frozen_string_literal: true

module Vessel
  class Engine
    def self.run(*args)
      new(*args).tap(&:run)
    end

    attr_reader :crawler_class, :settings, :scheduler, :middleware

    def initialize(klass, &block)
      @crawler_class = klass
      @settings = klass.settings
      @middleware = block || Middleware.build(settings[:middleware])
      @queue = SizedQueue.new(settings[:max_threads])
      @scheduler = Scheduler.new(@queue, settings)
    end

    def run
      scheduler.post(*start_requests)

      until @queue.closed?
        message = @queue.pop
        raise message if message.is_a?(Exception)
        handle(*message)
        @queue.close if idle?
      end
    end

    def handle(browser, request)
      crawler = @crawler_class.new(@settings[:domain], browser)
      crawler.send(request.method) do |object|
        if object.is_a?(Request)
          scheduler.post(object)
        else
          @middleware.call(object)
        end
      end
    ensure
      browser.quit
    end

    def start_requests
      Request.build(*settings[:start_urls])
    end

    def idle?
      @queue.empty? &&
      @scheduler.queue_length.zero? &&
      @scheduler.scheduled_task_count == @scheduler.completed_task_count
    end
  end
end
