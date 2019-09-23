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
      CrawlerWithDomain = Class.new(Vessel::Cargo) { domain "blabla" }
      crawler = CrawlerWithDomain.new
      expect(crawler.domain).to eq("blabla")
    end
  end
end
