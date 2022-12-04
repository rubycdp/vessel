# frozen_string_literal: true

$LOAD_PATH.unshift(Dir.pwd) unless $LOAD_PATH.include?(Dir.pwd)
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup"
Bundler.require(:default)
Bundler.require(Vessel.env.to_sym)

require "lib/loader"
Vessel.loader = ApplicationLoader.new

Dir["config/environments/*.rb"].sort.each { |f| require f }
Dir["config/environments/#{Vessel.env}/*.rb"].sort.each { |f| require f }
Dir["config/middleware/*.rb"].sort.each { |f| require f }
Dir["lib/helpers/*.rb"].sort.each { |f| require f }
Dir["config/fields/*.rb"].sort.each { |f| require f }
