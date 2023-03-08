# frozen_string_literal: true

require "spec_helper"

module Vessel
  describe Cargo do
    describe ".domain" do
      # rubocop:disable Lint/ConstantDefinitionInBlock
      it "shows default", skip: true do
        CrawlerWithoutDomain = Class.new(Vessel::Cargo)
        crawler = CrawlerWithoutDomain.new

        expect(crawler.domain).to eq("crawlerwithoutdomain")
      end

      it "shows set" do
        CrawlerWithDomain = Class.new(Vessel::Cargo) { domain "blablabla" }
        crawler = CrawlerWithDomain.new

        expect(crawler.domain).to eq("blablabla")
      end
      # rubocop:enable Lint/ConstantDefinitionInBlock
    end

    describe ".start_urls" do
      it "accepts string" do
        crawler = Class.new(Vessel::Cargo) { start_urls "blablabla" }

        expect(crawler.settings[:start_urls]).to eq("blablabla" => :parse)
      end

      it "accepts multiple strings" do
        crawler = Class.new(Vessel::Cargo) { start_urls "1", "2" }

        expect(crawler.settings[:start_urls]).to eq("1" => :parse, "2" => :parse)
      end

      it "accepts array" do
        crawler = Class.new(Vessel::Cargo) { start_urls %w[1 2] }

        expect(crawler.settings[:start_urls]).to eq("1" => :parse, "2" => :parse)
      end

      it "accepts hash" do
        crawler = Class.new(Vessel::Cargo) { start_urls "1" => :parse_one, "2" => :parse_two }

        expect(crawler.settings[:start_urls]).to eq("1" => :parse_one, "2" => :parse_two)
      end
    end

    describe ".settings" do
      it "copies settings to the subclasses" do
        parent = Class.new(Vessel::Cargo) do
          headers "Test" => "test"
          cookies [
            { name: "lang", value: "en", domain: "www.google.com", path: "/" }
          ]
        end
        child = Class.new(parent)

        expect(child.settings[:headers]).to eq(parent.settings[:headers])
        expect(child.settings[:headers]).not_to equal(parent.settings[:headers])

        expect(child.settings[:cookies]).to eq(parent.settings[:cookies])
        expect(child.settings[:cookies]).not_to equal(parent.settings[:cookies])
        expect(child.settings[:cookies][0]).not_to equal(parent.settings[:cookies][0])
      end
    end

    describe ".run" do
      it "merges with default settings" do
        allow(Engine).to receive(:run)
        crawler = Class.new(Vessel::Cargo) do
          domain "blabla.com"
          start_urls "http://www.blabla.com"
          threads max: 5
        end

        crawler.run(domain: "alabama.com",
                    start_urls: ["http://www1.alabama.com",
                                 "http://www2.alabama.com"])

        expect(crawler.settings[:delay]).to eq(0)
        expect(crawler.settings[:start_urls]).to eq([
          "http://www1.alabama.com",
          "http://www2.alabama.com"
        ])
        expect(crawler.settings[:middleware]).to eq([])
        expect(crawler.settings[:min_threads]).to eq(1)
        expect(crawler.settings[:max_threads]).to eq(5)
        expect(crawler.settings[:headers]).to eq(nil)
        expect(crawler.settings[:domain]).to eq("alabama.com")
      end
    end
  end
end
