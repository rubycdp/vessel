require "json"
require "vessel"

class QuotesToScrapeCom < Vessel::Cargo
  domain "quotes.toscrape.com"
  start_urls "http://quotes.toscrape.com/tag/humor/"
  ferrum browser_options: { "ignore-certificate-errors" => nil }

  def parse
    css("div.quote").each do |quote|
      yield({
        author: quote.at_xpath("span/small").text,
        text: quote.at_css("span.text").text
      })
    end

    if next_page = at_xpath("//li[@class='next']/a[@href]")
      url = absolute_url(next_page.attribute(:href))
      yield request(url: url, method: :parse)
    end
  end
end

quotes = []
QuotesToScrapeCom.run { |q| quotes << q }
puts JSON.generate(quotes)
