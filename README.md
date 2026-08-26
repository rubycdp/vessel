# Vessel - high-level web crawling framework

#### Fast as Chrome, dead simple and yet extendable.

Vessel is a Ruby high-level web crawling framework. It can be used in a wide range of scenarios, like data
mining, monitoring or historical archival. Pages are fetched by a pluggable
driver: [Ferrum](https://github.com/rubycdp/ferrum) (a real Chrome, the default)
or [Mechanize](https://github.com/sparklemotion/mechanize) (plain HTTP, no
browser). For automated testing we recommend
[Cuprite](https://github.com/rubycdp/cuprite).


## Install

Add this to your Gemfile:

```ruby
gem "vessel"
```

The default `:ferrum` driver needs Chrome or Chromium installed and available in `PATH`.


## A look around

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

    yield request(url: absolute_url(next_page.attribute(:href)), handler: :parse)
  end
end

quotes = []
QuotesToScrapeCom.run { |q| quotes << q }
puts JSON.generate(quotes)
```

Save this to `quotes.rb` file and run `bundle exec ruby quotes.rb > quotes.json`.
When this finishes you will have a list of the quotes in JSON format in the
`quotes.json` file. Vessel logs to `$stdout` at the debug level by default, so
either send the log somewhere else (see [Logging](#logging)) or write your items
to a file instead of `$stdout`.

How it all works? First Vessel using the driver goes to one or more urls in
`start_urls`, in our case it's only one. After the page is loaded with all the
resources it needs the handler for that url is invoked, `parse` by default. In
the parse handler, we loop through the quote elements using a CSS Selector,
yield a Hash with the extracted quote text and author and look for a link to the
next page and schedule another request using the same parse method as a handler.

Notice that all requests are scheduled and handled concurrently. We use a thread
pool to work with all your requests with one page per core by default or add
`threads max: n` to a class. If you yield more than one request Ruby will send
them to the driver which will load pages in parallel. Thus crawler is
lightweight and speedy.

`Vessel::Crawler` is an alias for `Vessel::Cargo`, both names work.


## Settings

Settings are declared in the class body and are inherited by (and deep-copied
into) subclasses, which is what makes a shared `ApplicationCrawler` base class
useful:

| Setting | Description |
| --- | --- |
| [`domain`](#domain) | Domain name of the crawler, also registers it in the loader |
| [`start_urls`](#start_urls) | Urls to start with, optionally mapped to handlers |
| [`driver`](#driver) | Driver to fetch pages with and its options |
| [`delay`](#delay) | Seconds (or a range) to wait between requests |
| [`headers`](#headers) | Request headers |
| [`cookie` / `cookies`](#cookies) | Cookies to set before a request |
| [`allow_cookies`](#cookies) | Whether cookies received from a page are kept for the next requests |
| [`threads`](#threads) | Min and max size of the thread pools |
| [`middleware`](#middleware) | Pipeline the yielded items go through |
| [`proxy`](#proxy) | Proxy rotation class |
| [`blacklist` / `whitelist`](#blacklist-and-whitelist) | Patterns of the resources to block or to allow |
| [`network_error_attempts`](#network_error_attempts) | How many times a request is retried on a network error |

Every setting can also be passed at runtime to `.run`, which merges it on top of
the class-level ones:

```ruby
QuotesToScrapeCom.run(delay: 2, max_threads: 1)
```

### domain

```ruby
class MyScraper < Vessel::Cargo
  domain "example.com"
end
```

The domain is used as the crawler name for the CLI and as the default domain for
[cookies](#cookies).

### start_urls

Accepts strings, an array of strings or a hash of `url => handler`, so different
entry points can be parsed by different methods. Without a handler `:parse` is
used:

```ruby
class MyScraper < Vessel::Cargo
  start_urls "https://example.com/one", "https://example.com/two"
  # or
  start_urls "https://example.com/products" => :parse_products,
             "https://example.com/news" => :parse_news
end
```

If `start_urls` is empty the crawler is still started once with a stub response,
which is handy when the first urls are computed in `parse` itself.

### driver

```ruby
class MyScraper < Vessel::Cargo
  driver :ferrum, headless: true, timeout: 30
end
```

Two drivers ship with Vessel:

* `:ferrum` (default) - a real Chrome driven by
  [Ferrum](https://github.com/rubycdp/ferrum), options are passed to
  `Ferrum::Browser.new`. Vessel defaults to `timeout: 60`, `js_errors: false`,
  `process_timeout: 30`, `pending_connection_errors: false` and ignoring
  certificate errors.
* `:mechanize` - plain HTTP requests via
  [Mechanize](https://github.com/sparklemotion/mechanize), no browser and no
  JavaScript, which makes it much faster and lighter. `blacklist` and
  `whitelist` are not supported by this driver.

You can disable headless mode by passing driver options at runtime:

```ruby
MyScraper.run(driver_options: { headless: false })
```

Custom drivers are supported, subclass `Vessel::Driver`, implement `start`,
`stop` and `create_page` along with a `Vessel::Driver::Page` subclass, and
register it with `driver_name :my_driver`.

### delay

```ruby
class MyScraper < Vessel::Cargo
  delay 4..6
  threads max: 1
end
```

Number of seconds to keep between two consecutive requests, a range is sampled
randomly per request. The delay is only applied when the crawler is single
threaded, with a pool of more than one thread it doesn't make sense.

### headers

```ruby
class MyScraper < Vessel::Cargo
  headers "Content-Type" => "text/plain",
          "Referer" => "https://example.com"
end
```

### cookies

`cookie` sets one cookie, `cookies` takes an array of them. `domain` defaults to
the crawler's `domain`:

```ruby
class MyScraper < Vessel::Cargo
  domain "example.com"

  cookie name: "lang", value: "en", path: "/"
  cookies [
    { name: "session", value: "abc", domain: "example.com", path: "/" },
    { name: "consent", value: "1", domain: "example.com", path: "/", secure: true }
  ]
end
```

Supported keys are `name`, `value`, `domain`, `path`, `httponly`, `secure` and
`expires`. By default cookies collected from a response are stored and sent with
the following requests, `allow_cookies false` turns that off.

### threads

```ruby
class MyScraper < Vessel::Cargo
  threads min: 1, max: 5
end
```

`max` defaults to the number of the processors, the same pool size is used both
for fetching pages and for running the middleware.

### proxy

Subclass `Vessel::RoundRobinProxy` (or `Vessel::ShuffledProxy` to shuffle the
list on start) and define the `PROXIES` constant, the driver takes the next
proxy for every page it creates:

```ruby
class MyProxy < Vessel::ShuffledProxy
  PROXIES = [
    { host: "127.0.0.1", port: 8080, user: "user1", password: "password1" },
    { host: "127.0.0.1", port: 8081, user: "user2", password: "password2" }
  ].freeze
end

class MyScraper < Vessel::Cargo
  proxy MyProxy
end
```

For a fully custom rotation subclass `Vessel::Proxy` and implement `prepare`,
which is called once and fills in `@proxies`.

### blacklist and whitelist

Patterns of the resources Chrome is allowed to load, useful to skip images,
fonts or trackers and speed the crawler up. Ferrum driver only:

```ruby
class MyScraper < Vessel::Cargo
  blacklist [/\.png$/, /googletagmanager/]
  # or
  whitelist [/example.com/]
end
```

### network_error_attempts

```ruby
class MyScraper < Vessel::Cargo
  network_error_attempts 5
end
```

How many times a url is retried when the driver raises a network error, e.g. a
timeout, a socket error or a bad status. The browser is restarted between the
attempts. Defaults to `5`. When the attempts are exhausted the error is passed
to the [`on_error`](#callbacks) callback.


## Requests

Inside a handler `request` builds a new request relative to the current page,
yield it and the engine schedules it:

```ruby
def parse
  yield request(url: "/page/2/", handler: :parse_page, data: { category: "humor" })
end

def parse_page
  puts response.data[:category] # => "humor"
end
```

| Option | Description |
| --- | --- |
| `url` | Absolute or relative url, resolved against the current page |
| `handler` | Method to call with the response, `:parse` by default, `callback` is an alias |
| `data` | Arbitrary hash carried over to the response, deep-copied |
| `delay` | Overrides the crawler `delay` for this request |
| `headers` | Overrides the crawler `headers` for this request |
| `cookies` | Overrides the crawler `cookies` for this request |
| `once` | `true` by default, the same url is not visited twice, pass `false` to allow it |
| `encode` | `true` by default, the url is decoded and encoded again before it's joined |

You can yield a single request, an array of them, or a hash of the extracted
fields, but not both in one `yield`.


## Selectors

The response is delegated to the crawler, so inside a handler you can call
directly:

* `at_css`, `css`, `at_xpath`, `xpath` - search the page
* `url`, `data`, `attempt`, `size`, `body`, `raw` - the current url, the data
  attached to the request, which attempt it is, the page size in bytes, the
  Nokogiri document and the raw html
* `absolute_url`, `join_url`, `url_encode`, `url_decode` (aliased as
  `uri_encode`, `uri_decode`) - url helpers

`response` and `page` are available as well, `page` being the driver's native
object, `Ferrum::Page` or `Mechanize::Page`. `response.status` and
`response.headers` give you the response status and headers,
`response.sync_body` re-reads the html after a pause when the page needs a
moment to render.

By default the selectors run against the live page, which for the Ferrum driver
means Chrome does the querying. Setting `Vessel.page_snapshot = true` makes them
run against the Nokogiri document of the page's html instead, which is much
faster when you extract a lot of nodes and don't need to interact with the page.


## Fields

Instead of building a hash by hand a handler can declare fields and yield the
collected `fields` object:

```ruby
class MyScraper < Vessel::Cargo
  def parse
    field :author, value: at_xpath("span/small").text
    field :text, value: at_css("span.text").text
    field :html, value: nil, service: true do
      raw
    end

    yield fields
  end
end
```

* a block is called instead of `value` when it's given
* `service: true` keeps the field out of the resulting hash, it's only available
  as `fields.service[:name]` in the middleware
* `rename: { "author" => :writer }` stores the field under another name

Fields can be normalized in one place by their name, put such declarations into
`config/fields` of a generated project:

```ruby
Vessel::Cargo::FieldType.add(:price) { |value| value.to_s.gsub(/[^\d.]/, "").to_f }
```

Every `field :price` is then passed through that block, `typing: false` skips it.


## Middleware

Everything a handler yields that is not a request goes through the middleware
pipeline, which runs in its own thread pool. A middleware is a class with a
`call(hash, fields)` method, it gets the hash returned by the previous
middleware plus the original fields object, and returns the hash for the next
one:

```ruby
class Sanitize < Vessel::Middleware
  def call(hash, fields)
    hash.transform_values { |v| v.is_a?(String) ? v.strip : v }
  end
end

class Save < Vessel::Middleware
  def call(hash, fields)
    raise Vessel::Middleware::InvalidItemError if hash[:text].to_s.empty?

    DB[:quotes].insert(hash)
    hash
  end
end

class MyScraper < Vessel::Cargo
  middleware "Sanitize", "Save"
end
```

Middleware is declared by name so that classes can be defined anywhere in the
project, the crawler settings are available as `settings`. Raising
`Vessel::Middleware::InvalidItemError` silently rejects the item, any other
error is logged and counted as a rejection too.

A block passed to `.run` replaces the whole pipeline, which is the shortest way
to collect the items in a script:

```ruby
QuotesToScrapeCom.run { |item| quotes << item }
```


## Callbacks

Override any of these in the crawler to hook into the run:

```ruby
class MyScraper < Vessel::Cargo
  def before_start; end            # before anything is scheduled
  def before(stats); end           # with the initial stats
  def after_change(counter, stats) # on every stats counter change
  end
  def info(stats); end             # every 4 seconds, logs the stats by default
  def after(stats); end            # when the engine is done
  def before_stop; end             # at exit
  def on_error(request, error); end # a request failed, re-raises by default
end
```

The stats hash holds `req_enqueued`, `res_dequeued`, `res_handled`,
`item_pipelined`, `item_processed`, `item_sent`, `item_rejected` and `idling`.


## Logging

Vessel logs to `$stdout` at the debug level. Pass your own logger to change
that:

```ruby
Vessel::Logger.instance = Logger.new("log/vessel.log", level: Logger::INFO)
```


## Projects and CLI

A single-file script is enough for a small crawler, for a bigger one Vessel can
generate a project:

```
$ vessel new myproject
$ cd myproject
$ bundle install
$ vessel generate example.com
```

```
myproject
├── Gemfile
├── config
│   ├── boot.rb                      # loads everything below
│   ├── environments
│   │   ├── dev/dev.rb               # ApplicationCrawler for VESSEL_ENV=dev
│   │   └── prod/prod.rb             # ApplicationCrawler for VESSEL_ENV=prod
│   ├── fields                       # FieldType declarations
│   └── middleware                   # middleware classes
├── crawlers                         # one crawler per site
├── lib
│   ├── helpers
│   └── loader.rb
└── log
```

Crawlers inherit from `ApplicationCrawler`, which is defined per environment, so
the settings can differ between development and production, `VESSEL_ENV`
selects the environment and defaults to `dev`.

| Command | Description |
| --- | --- |
| `vessel new NAME` | Generate a new project |
| `vessel generate DOMAIN` | Generate `crawlers/DOMAIN.rb` |
| `vessel list` | List the crawlers of the project |
| `vessel settings DOMAIN` | Show the settings of a crawler |
| `vessel start DOMAIN` | Run a crawler |
| `vessel parse DOMAIN URL HANDLER --data=key:value` | Fetch one url and call one handler, for debugging |
| `vessel version` | Print the version |


## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
