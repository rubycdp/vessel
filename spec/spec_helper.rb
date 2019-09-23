# frozen_string_literal: true

require "bundler/setup"
require "rspec"

PROJECT_ROOT = File.expand_path("..", __dir__)
%w[/lib /spec].each { |p| $:.unshift(p) }

require "vessel"

RSpec.configure do |config|
end
