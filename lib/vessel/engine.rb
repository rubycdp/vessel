# frozen_string_literal: true

module Vessel
  class Engine
    def self.run(*args, &block)
      new(*args, &block).tap(&:run)
    end

    attr_reader :crawler_class, :settings, :scheduler, :middleware

    def initialize(klass, &block)
      @crawler_class = klass
      @settings = klass.settings
      @middleware = block || Middleware.build(*settings[:middleware])
      @queue = SizedQueue.new(settings[:max_threads])
      @scheduler = Scheduler.new(@queue, settings)
    end

    def run
      scheduler.post(*start_requests)

      until @queue.closed?
        message = @queue.pop

        raise(message) if message.is_a?(Exception)

        page, request = message
        args = [request.method, request.data].compact
        handle(page, args)

        @queue.close if idle?
      end
    end

    def handle(page, args)
      crawler = @crawler_class.new(page)
      crawler.send(*args) do |*result|
        if result.all? { |i| i.is_a?(Request) }
          scheduler.post(*result)
        else
          @middleware&.call(*result)
        end
      end
    ensure
      page.close if page
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
