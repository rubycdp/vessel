# frozen_string_literal: true

require "spec_helper"

module Vessel
  describe Cargo do
    it "shows default name" do
      CrawlerWithoutDomain = Class.new(Vessel::Cargo)
      crawler = CrawlerWithoutDomain.new
      expect(crawler.domain).to eq("crawlerwithoutdomain")
    end

    it "shows set name" do
      CrawlerWithDomain = Class.new(Vessel::Cargo) { domain "blablabla" }
      crawler = CrawlerWithDomain.new
      expect(crawler.domain).to eq("blablabla")
    end

    it "overrides name" do
      allow(Engine).to receive(:run)
      CrawlerOne = Class.new(Vessel::Cargo) do
        domain "blabla.com"
        start_urls "http://www.blabla.com"
      end

      CrawlerOne.run(domain: "alabama.com",
                            start_urls: ["http://www1.alabama.com",
                                         "http://www2.alabama.com"])

      expect(CrawlerOne.settings[:domain]).to eq("alabama.com")
      expect(CrawlerOne.settings[:start_urls])
        .to eq(["http://www1.alabama.com", "http://www2.alabama.com"])
    end
  end
end
