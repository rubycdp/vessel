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
        page, request, error = message
        handle(page, request, error)
        @queue.close if idle?
      end

    ensure
      scheduler.stop
    end

    def handle(page, request, error)
      crawler = @crawler_class.new(page)

      raise(error) if error && !crawler.respond_to?(:on_error)

      args = error ? [:on_error, request, error] : [request.handler, request.data].compact

      crawler.send(*args) do |*result|
        if result.flatten.all? { |i| i.is_a?(Request) }
          scheduler.post(*result.flatten)
        else
          @middleware&.call(*result)
        end
      end
    ensure
      page.close if page
    end

    private

    def start_requests
      Request.build(settings[:url_handlers])
    end

    def idle?
      @queue.empty? &&
      @scheduler.queue_length.zero? &&
      @scheduler.scheduled_task_count == @scheduler.completed_task_count
    end
  end
end
