# Vessel - high-level web crawling framework

#### Fast as Chrome, dead simple and yet extendable.

It is Ruby high-level web crawling framework based on
[Ferrum](https://github.com/rubycdp/ferrum) for extracting the data you need
from websites. It can be used in a wide range of scenarios, like data mining,
monitoring or historical archival. For automated testing we recommend
[Cuprite](https://github.com/rubycdp/cuprite).

Thanks to Evrone [design team](https://evrone.com/design?utm_source=github&utm_campaign=vessel). Read about [Vessel](https://evrone.com/vessel-framework?utm_source=github&utm_campaign=vessel) & other projects supported by Evrone [here](https://evrone.com/cases?utm_source=github&utm_campaign=vessel#open-source).


## Install

Add this to your Gemfile:

```ruby
gem "vessel"
```


## A look around

In order to show you how Vessel works we are going to crawl together
[famous quotes website](http://quotes.toscrape.com):

```ruby
require "json"
require "vessel"

class QuotesToScrapeCom < Vessel::Cargo
  domain "quotes.toscrape.com"
  start_urls "http://quotes.toscrape.com/tag/humor/"

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
```

Save this to `quotes.rb` file and run `bundle exec ruby quotes.rb > quotes.json`.
When this finishes you will have a list of the quotes in JSON format in the
`quotes.json` file.

How it all works? First Vessel using Ferrum spawns Chrome which goes to one or
more urls in `start_urls`, in our case it's only one. After Chrome reports back
that page is loaded with all the resources it needs the first default callback
`parse` is invoked. In the parse callback, we loop through the quote elements
using a CSS Selector, yield a Hash with the extracted quote text and author and
look for a link to the next page and schedule another request using the same
parse method as callback.

Notice that all requests are scheduled and handled concurrently. We use thread
pool to work with all your requests with one page per core by default or add
`threads max: n` to a class. If you yield more than one request Ruby will send
them to Chrome which will load pages in parallel. Thus crawler is lightweight
and speedy.


## Settings

* domain
* start_urls
* delay
* timeout
* threads
* middleware


## Selectors

* at_css
* css
* at_xpath
* xpath


## Middleware

To be continued


## License

Copyright 2018-2020 Machinio

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
