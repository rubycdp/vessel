# frozen_string_literal: true

require_relative "lib/vessel/version"

Gem::Specification.new do |s|
  s.name          = "vessel"
  s.version       = Vessel::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Dmitry Vorotilin"]
  s.email         = ["d.vorotilin@gmail.com"]
  s.homepage      = "https://github.com/rubycdp/vessel"
  s.summary       = "High-level web crawling framework"
  s.description   = "Vessel is a high-level web crawling framework, used to crawl websites and "\
                    "extract structured data from their pages"
  s.license       = "MIT"
  s.files         = Dir.chdir(__dir__) do
    tracked = `git ls-files -z bin lib CHANGELOG.md LICENSE README.md`.split("\x0")
    next tracked unless tracked.empty? # built outside of a git checkout

    Dir.glob("{bin/*,lib/**/*,CHANGELOG.md,LICENSE,README.md}", File::FNM_DOTMATCH)
       .grep_v(%r{/\.\.?\z})
  end
  s.bindir        = "bin"
  s.executables   = ["vessel"]
  s.require_paths = ["lib"]
  s.metadata = {
    "homepage_uri" => "https://vessel.rubycdp.com/",
    "bug_tracker_uri" => "https://github.com/rubycdp/vessel/issues",
    "changelog_uri" => "https://github.com/rubycdp/vessel/blob/main/CHANGELOG.md",
    "documentation_uri" => "https://github.com/rubycdp/vessel/blob/main/README.md",
    "source_code_uri" => "https://github.com/rubycdp/vessel",
    "rubygems_mfa_required" => "true"
  }

  s.required_ruby_version = ">= 2.7.0"

  s.add_runtime_dependency "ferrum", ">= 0.15"
  s.add_runtime_dependency "mechanize", ">= 2.8.5"
  s.add_runtime_dependency "nokogiri", "~> 1.13"
  s.add_runtime_dependency "thor", "~> 1.2"

  s.add_development_dependency "bundler", "~> 2.3"
  s.add_development_dependency "rake", "~> 13.0"
  s.add_development_dependency "rspec", "~> 3.11"
end
