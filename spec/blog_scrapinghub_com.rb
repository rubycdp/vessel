require "vessel"

class Debug1 < Vessel::Middleware
  def call(item)
    puts "Debug1"
    middleware.call(item)
  end
end

class Debug2 < Vessel::Middleware
  def call(item)
    puts "Debug2"
    puts item
  end
end

class BlogScrapinghubCom < Vessel::Cargo
  domain "blog.scrapinghub.com"
  start_urls "https://blog.scrapinghub.com"
  # threads max: 2
  timeout 20
  middleware Debug1, Debug2

  def parse
    css(".post-header>h2>a").each do |a|
      yield request(url: a.attribute(:href), method: :parse_article)
    end

    css("a.next-posts-link").each do |a|
      yield request(url: a.attribute(:href), method: :parse)
    end
  end

  def parse_article
    yield browser.title
  end
end

BlogScrapinghubCom.run

# BlogScrapinghubCom.run do |data|
#   puts data
# end
