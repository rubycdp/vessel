# frozen_string_literal: true

require "logger"
require "forwardable"

module Vessel
  class Logger
    class << self
      extend Forwardable
      delegate %i[debug info warn error] => :instance

      attr_writer :instance

      def instance
        @instance ||= begin
          $stdout.sync = true
          instance = ::Logger.new($stdout)
          instance.level = ::Logger::DEBUG
          instance
        end
      end
    end
  end
end
