# frozen_string_literal: true

require "json"
require "vessel"

# class MyProxy < Vessel::ShuffledProxy
#   @proxy1 = Ferrum::Proxy.start(user: "user1", password: "password1")
#   @proxy2 = Ferrum::Proxy.start(user: "user2", password: "password2")
#
#   PROXIES = [
#     { host: @proxy1.host, port: @proxy1.port, user: "user1", password: "password1" },
#     { host: @proxy2.host, port: @proxy2.port, user: "user2", password: "password2" }
#   ].freeze
# end

class QuotesDotToScrapeDotCom < Vessel::Cargo
  domain "quotes.toscrape.com"
  start_urls "https://quotes.toscrape.com/tag/humor/"
  headers "User-Agent" => "Browser", "Test" => "test"
  cookies [
    { name: "lang", value: "en", domain: "www.google.com", path: "/" },
    { name: "lang", value: "en", domain: "www.google.com", path: "/path" }
  ]
  # blacklist /bla-bla/
  # whitelist /quotes.toscrape.com/
  # proxy MyProxy

  def parse
    css("div.quote").each do |quote|
      yield({
        author: quote.at_xpath("span/small").text,
        text: quote.at_css("span.text").text
      })
    end

    next_page = at_xpath("//li[@class='next']/a[@href]")
    return unless next_page

    yield request(url: absolute_url(next_page[:href]), handler: :parse)
  end
end

quotes = []
QuotesDotToScrapeDotCom.run { |q| quotes << q }
puts JSON.generate(quotes)
