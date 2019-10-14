# frozen_string_literal: true

require "concurrent-ruby"
require "vessel/engine"
require "vessel/middleware"
require "vessel/scheduler"
require "vessel/request"
require "vessel/version"
require "vessel/cargo"

module Vessel
  class Error < StandardError; end
  class NotImplementedError < Error; end
end
