# frozen_string_literal: true

require_relative "lib/vessel/version"

Gem::Specification.new do |s|
  s.name          = "vessel"
  s.version       = Vessel::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Dmitry Vorotilin"]
  s.email         = ["d.vorotilin@gmail.com"]
  s.homepage      = "https://github.com/route/vessel"
  s.summary       = "High-level web crawling framework"
  s.description   = "Vessel is a high-level web crawling framework, used to crawl websites and "\
                    "extract structured data from their pages"
  s.license       = "MIT"
  s.files         = Dir["bin/*", "lib/**/*", "LICENSE", "README.md"]
  s.bindir        = "bin"
  s.executables   = ["vessel"]
  s.require_paths = ["lib"]
  s.metadata = {
    "homepage_uri" => "https://vessel.rubycdp.com/",
    "bug_tracker_uri" => "https://github.com/rubycdp/vessel/issues",
    "documentation_uri" => "https://github.com/rubycdp/vessel/blob/main/README.md",
    "source_code_uri" => "https://github.com/rubycdp/vessel",
    "rubygems_mfa_required" => "true"
  }

  s.required_ruby_version = ">= 2.6.0"

  s.add_runtime_dependency "ferrum", "~> 0.12"
  s.add_runtime_dependency "mechanize", ">= 2.8.5"
  s.add_runtime_dependency "nokogiri", "~> 1.13"
  s.add_runtime_dependency "thor", "~> 1.2"

  s.add_development_dependency "bundler", "~> 2.3"
  s.add_development_dependency "rake", "~> 13.0"
  s.add_development_dependency "rspec", "~> 3.11"
end
