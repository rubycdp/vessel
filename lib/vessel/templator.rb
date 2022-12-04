# frozen_string_literal: true

module Vessel
  class Templator
    TEMPLATES = "templates/*.erb"

    def initialize(domain, options)
      @domain = domain
      @options = options
      @class_name = @domain.gsub("-", ".dash.").split(".").map(&:capitalize).join
    end

    def build
      abort "Template #{template_path} not found" unless File.file?(template_path)

      file = File.read(template_path)
      evaluated = ERB.new(file).result(binding)
      Logger.debug("Templator: creating file #{store_path}")
      File.open(store_path, "w+") << evaluated
    end

    private

    def template_path
      File.expand_path("templates/template.erb", __dir__)
    end

    def store_path
      "crawlers/#{@domain}.rb"
    end
  end
end
