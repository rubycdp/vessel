# frozen_string_literal: true

module Vessel
  class Driver
    class Page
      attr_reader :browser, :page

      def initialize(browser)
        @browser = browser
        create
      end

      def create
        raise NotImplementedError
      end

      def close
        raise NotImplementedError
      end

      def go_to(url)
        raise NotImplementedError
      end

      def blacklist=(patterns)
        raise NotImplementedError
      end

      def headers=(headers)
        raise NotImplementedError
      end

      def headers
        raise NotImplementedError
      end

      def cookies=(cookies)
        raise NotImplementedError
      end

      def cookies
        raise NotImplementedError
      end

      def proxy=(ip:, port:, type: nil, user: nil, password: nil)
        raise NotImplementedError
      end

      def status
        raise NotImplementedError
      end

      def body
        raise NotImplementedError
      end

      def size
        raise NotImplementedError
      end

      def full_response
        [status, headers, body]
      end
    end
  end
end
