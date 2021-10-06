lib = File.expand_path("lib", __dir__)
$:.unshift(lib) unless $:.include?(lib)

require "vessel/version"

Gem::Specification.new do |s|
  s.name          = "vessel"
  s.version       = Vessel::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Dmitry Vorotilin"]
  s.email         = ["d.vorotilin@gmail.com"]
  s.homepage      = "https://github.com/route/vessel"
  s.summary       = "High-level web crawling framework"
  s.description   = "Vessel is a high-level web crawling framework, used to crawl websites and extract structured data from their pages"
  s.license       = "MIT"
  s.require_paths = ["lib"]
  s.files         = Dir["{lib}/**/*"] + %w[LICENSE README.md]
  s.metadata = {
    "homepage_uri" => "https://vessel.rubycdp.com/",
    "bug_tracker_uri" => "https://github.com/rubycdp/vessel/issues",
    "documentation_uri" => "https://github.com/rubycdp/vessel/blob/master/README.md",
    "source_code_uri" => "https://github.com/rubycdp/vessel",
  }

  s.required_ruby_version = ">= 2.3.0"

  s.add_runtime_dependency "ferrum", ">= 0.8"
  s.add_runtime_dependency "mechanize", ">= 2.8.2"
  s.add_runtime_dependency "thor", "~> 1.0"

  s.add_development_dependency "bundler", "~> 2.0"
  s.add_development_dependency "rake", "~> 12.3"
  s.add_development_dependency "rspec", "~> 3.8"
end
