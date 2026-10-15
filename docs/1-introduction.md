---
sidebar_position: 1
---

# Introduction

Vessel is a high-level web crawling framework for Ruby. Fast as Chrome, dead
simple and yet extendable.

<img align="right"
     width="160" height="160"
     alt="Vessel logo"
     src="https://raw.githubusercontent.com/rubycdp/vessel/main/logo.svg?sanitize=true" />

It can be used in a wide range of scenarios, like data mining, monitoring or
historical archival. Pages are fetched by a pluggable [driver](/docs/vessel/drivers):
[Ferrum](/docs/ferrum/introduction) (a real Chrome, the default) or
[Mechanize](https://github.com/sparklemotion/mechanize) (plain HTTP, no
browser). For automated testing we recommend
[Cuprite](/docs/cuprite/introduction).

<br clear="right" />

## Installation

Add this to your `Gemfile` and run `bundle install`.

```ruby
gem "vessel"
```

The default `:ferrum` driver needs Chrome or Chromium installed, see
[Ferrum installation](/docs/ferrum/introduction#installation).

The `:mechanize` driver is optional and ships as a sibling dependency, so add it
to your `Gemfile` when you want to use it:

```ruby
gem "mechanize"
gem "vessel"
```

## Quick Start

In order to show you how Vessel works we are going to crawl together
[famous quotes website](https://quotes.toscrape.com):

```ruby
require "json"
require "vessel"

class QuotesToScrapeCom < Vessel::Cargo
  domain "quotes.toscrape.com"
  start_urls "https://quotes.toscrape.com/tag/humor/"

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
QuotesToScrapeCom.run { |q| quotes << q }
puts JSON.generate(quotes)
```

Save this to `quotes.rb` file and run `bundle exec ruby quotes.rb > quotes.json`.
When this finishes you will have a list of the quotes in JSON format in the
`quotes.json` file. Vessel logs to `$stdout` at the debug level by default, so
either send the log somewhere else (see [Logging](/docs/vessel/logging)) or
write your items to a file instead of `$stdout`.

`Vessel::Crawler` is an alias for `Vessel::Cargo`, both names work.

## How it works

First Vessel using the driver goes to one or more urls in `start_urls`, in our
case it's only one. After the page is loaded with all the resources it needs
the handler for that url is invoked, `parse` by default. In the parse handler,
we loop through the quote elements using a CSS selector, yield a `Hash` with the
extracted quote text and author and look for a link to the next page and
schedule another [request](/docs/vessel/requests) using the same parse method as
a handler.

Everything a handler yields is either a request, which is scheduled, or an
item, which goes through the [middleware](/docs/vessel/middleware) pipeline.

All requests are scheduled and handled concurrently. Vessel uses a thread pool
with one page per core by default, or add [`threads max: n`](/docs/vessel/settings#threadsmin-1-max-processor_count)
to a class. If you yield more than one request they are sent to the driver which
loads pages in parallel. Thus crawler is lightweight and speedy.

The run ends when there are no requests left to fetch and no items left in the
pipeline. Press `Ctrl+C` to stop it earlier.
