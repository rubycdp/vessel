# frozen_string_literal: true

module Vessel
  class Driver
    class Page
      def close
        raise NotImplementedError
      end

      def go_to(_)
        raise NotImplementedError
      end

      def headers=(_)
        raise NotImplementedError
      end

      def headers
        raise NotImplementedError
      end

      def cookies=(_)
        raise NotImplementedError
      end

      def cookies
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

      def current_url
        raise NotImplementedError
      end

      def blacklist=(_)
        raise NotImplementedError
      end

      def whitelist=(_)
        raise NotImplementedError
      end

      def full_response
        [status, headers, body]
      end
    end
  end
end
