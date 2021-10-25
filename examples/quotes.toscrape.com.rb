require "json"
require "vessel"

class QuotesToScrapeCom < Vessel::Cargo
  domain "quotes.toscrape.com"
  start_urls "http://quotes.toscrape.com/tag/humor/"
  driver :ferrum, headless: true # or driver :mechanize
  headers "User-Agent" => "Browser"
  # network blacklist: /bla-bla/
  # network whitelist: /quotes.toscrape.com/
  # network stub: { /lorem/ => "Ipsum", /ipsum/ => "Lorem" }

  def parse
    css("div.quote").each do |quote|
      yield({
        author: quote.at_xpath("span/small").text,
        text: quote.at_css("span.text").text
      })
    end

    if next_page = at_xpath("//li[@class='next']/a[@href]")
      url = absolute_url(next_page[:href])
      yield request(url: url, handler: :parse)
    end
  end

  def on_error(request, error)
    raise error
  end
end

quotes = []
QuotesToScrapeCom.run { |q| quotes << q }
puts JSON.generate(quotes)
