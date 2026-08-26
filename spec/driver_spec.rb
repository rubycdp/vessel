# frozen_string_literal: true

require "spec_helper"

module Vessel
  describe Driver do
    # A driver that doesn't need a browser, it only counts the pages it opened.
    let(:driver_class) do
      Class.new(Driver) do
        attr_reader :pages

        def start
          @pages = Concurrent::Array.new
        end

        def stop; end

        def create_page(**)
          sleep 0.1 # opening a page is slow, that's where threads race for the same url
          page = Struct.new(:url) do
            def go_to(url)
              self.url = url
            end

            def method_missing(*); end

            def respond_to_missing?(*)
              true
            end
          end.new
          pages << page
          page
        end
      end
    end
    let(:settings) { Vessel::Cargo.settings.merge(network_error_attempts: 1) }
    let(:driver)   { driver_class.new(settings) }
    let(:url)      { "http://example.com/one" }

    describe "#go_to" do
      it "visits an url" do
        response, = driver.go_to(Request.new(url: url))

        expect(response.rejected).to be(false)
        expect(response.attempt).to eq(1)
        expect(driver.pages.size).to eq(1)
      end

      it "rejects an url it has already visited" do
        driver.go_to(Request.new(url: url))
        response, = driver.go_to(Request.new(url: url))

        expect(response.rejected).to be(true)
        expect(driver.pages.size).to eq(1)
      end

      it "visits an url again when once is false" do
        driver.go_to(Request.new(url: url))
        response, = driver.go_to(Request.new(url: url, once: false))

        expect(response.rejected).to be(false)
        expect(response.attempt).to eq(2)
        expect(driver.pages.size).to eq(2)
      end

      it "visits an url once when threads race for it" do
        threads = Array.new(5) { Thread.new { driver.go_to(Request.new(url: url)) } }
        responses = threads.map { |t| t.value.first }

        expect(responses.count { |r| !r.rejected }).to eq(1)
        expect(responses.count(&:rejected)).to eq(4)
        expect(driver.pages.size).to eq(1)
      end

      it "doesn't visit a stub request" do
        response, = driver.go_to(Request.new)

        expect(response.stub?).to be(true)
        expect(driver.pages).to be_empty
      end
    end
  end
end
