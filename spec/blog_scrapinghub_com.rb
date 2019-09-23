class BlogScrapinghubCom < Vessel::Cargo
  domain "blog.scrapinghub.com"
  start_urls "https://blog.scrapinghub.com"

  def parse
    css(".post-header>h2>a").each do |a|
      yield request(url: a.attribute(:href), method: :parse_article)
    end

    css("a.next-posts-link").each do |a|
      yield request(url: a.attribute(:href), method: :parse)
    end
  end

  def parse_article
    yield page.title
  end
end
