# frozen_string_literal: true

require "vessel/driver/page"
require "vessel/driver/registry"

module Vessel
  class Driver
    def self.driver_name(name)
      Registry.instance.register(name, self)
    end

    def self.direct_network_errors
      [
        ::Net::HTTP::Persistent::Error,
        ::Net::HTTPFatalError,
        ::Net::ReadTimeout,
        ::Net::OpenTimeout,
        ::SocketError,
        ::Errno::ECONNRESET
      ].freeze
    end

    def self.indirect_network_errors
      [].freeze
    end

    attr_reader :browser, :settings, :proxy

    def initialize(settings)
      @last_request = nil
      @settings = settings
      @visited_urls = Concurrent::Map.new { 0 }
      @proxy = settings[:proxy]&.new
      start
      at_exit { stop }
    end

    def start
      raise NotImplementedError
    end

    def stop
      raise NotImplementedError
    end

    def create_page(proxy: nil)
      raise NotImplementedError
    end

    def restart
      stop
      start
      true
    end

    def go_to(request)
      url = request.url.to_s
      response = Response.new(**request.to_handler)
      return [response, request] if request.stub?

      if request.once && visited?(url)
        Logger.info("Driver: rejecting #{url} visited #{@visited_urls[url]} time(s)")
        response.rejected = true
        return [response, request]
      end

      begin
        page = prepare_page(request)
        delay(request.delay)
        @visited_urls.compute(url) { |v| v.to_i + 1 }
        Logger.info("Driver: visiting #{url}, last_request = #{@last_request.to_i}")
        page.go_to(url)
        @last_request = Time.now.to_i
        response = Response.new(page: page, attempt: @visited_urls[url], **request.to_handler)
        [response, request]
      rescue StandardError => e
        if network_error?(e)
          Logger.error("Driver: network issue for #{url}, attempt ##{@visited_urls[url]}")
          Logger.error("Driver: #{e.class}: #{e.message}")
          restart && retry if @visited_urls[url] < settings[:network_error_attempts]
        end

        [response, request, e]
      end
    end

    private

    def visited?(url)
      @visited_urls[url].positive?
    end

    def proxy_options
      options = proxy&.next
      Logger.debug("Driver: setting proxy #{options[:host]}:#{options[:port]}") if options
      options
    end

    def delay(delay)
      # Delay is set between requests when we don't want to bombard server with them.
      # So it requires a crawler to be single threaded. Otherwise it doesn't make sense.
      return if settings[:max_threads] > 1
      return unless @last_request

      begin
        interval = @last_request + delay - Time.now.to_i
        raise if interval.positive?
      rescue RuntimeError
        sleep(interval)
        retry
      end
    end

    def prepare_page(request)
      page = create_page(proxy: proxy_options)
      page.blacklist = settings[:blacklist] if settings[:blacklist]
      page.whitelist = settings[:whitelist] if settings[:whitelist]
      page.headers = request.headers if request.headers
      page.cookies = request.cookies if request.cookies
      page
    end

    def network_error?(error)
      self.class.direct_network_errors.include?(error.class) ||
        self.class.indirect_network_errors.include?(error.cause.class)
    end
  end
end
