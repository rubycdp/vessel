# frozen_string_literal: true

require "bundler/setup"
require "rspec"

PROJECT_ROOT = File.expand_path("..", __dir__)
%w[/lib /spec].each { |p| $LOAD_PATH.unshift(p) }

require "vessel"

RSpec.configure do |config|
  config.before(:each) do
    allow(Vessel::Logger.instance).to receive(:debug)
    allow(Vessel::Logger.instance).to receive(:info)
  end
end
