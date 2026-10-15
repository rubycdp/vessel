---
sidebar_position: 2
---

# Settings

Settings are declared in the class body and are inherited by (and deep-copied
into) subclasses, which is what makes a shared `ApplicationCrawler` base class
useful:

```ruby
class ApplicationCrawler < Vessel::Cargo
  delay 4..6
  threads max: 1
end

class MyScraper < ApplicationCrawler
  domain "example.com"
  start_urls "https://example.com"
end
```

| Setting | Description |
| --- | --- |
| [`domain`](#domainvalue) | Domain name of the crawler, also registers it in the loader |
| [`start_urls`](#start_urlsurls) | Urls to start with, optionally mapped to handlers |
| [`driver`](/docs/vessel/drivers) | Driver to fetch pages with and its options |
| [`delay`](#delayvalue) | Seconds (or a range) to wait between requests |
| [`threads`](#threadsmin-1-max-processor_count) | Min and max size of the thread pools |
| [`network_error_attempts`](#network_error_attemptsvalue) | How many times a request is retried on a network error |
| [`headers`](/docs/vessel/headers-cookies#headers) | Request headers |
| [`cookie` / `cookies`](/docs/vessel/headers-cookies#cookies) | Cookies to set before a request |
| [`allow_cookies`](/docs/vessel/headers-cookies#allow_cookiesvalue) | Whether cookies received from a page are kept for the next requests |
| [`middleware`](/docs/vessel/middleware) | Pipeline the yielded items go through |
| [`proxy`](/docs/vessel/proxy) | Proxy rotation class |
| [`blacklist` / `whitelist`](/docs/vessel/resource-filtering) | Patterns of the resources to block or to allow |

## Runtime settings

Every setting can also be passed at runtime to `.run`, which merges it on top of
the class-level ones. Use the keys of the `settings` hash:

```ruby
QuotesToScrapeCom.run(delay: 2, max_threads: 1)
QuotesToScrapeCom.run(driver_options: { headless: false })
```

Available keys are `domain`, `start_urls`, `driver_name`, `driver_options`,
`delay`, `min_threads`, `max_threads`, `network_error_attempts`, `headers`,
`cookies`, `allow_cookies`, `middleware`, `proxy`, `blacklist` and `whitelist`.

Settings are also available as `settings` inside a crawler and a middleware.

#### domain(value)

```ruby
class MyScraper < Vessel::Cargo
  domain "example.com"
end
```

The domain is used as the crawler name for the [CLI](/docs/vessel/projects-cli)
and as the default domain for [cookies](/docs/vessel/headers-cookies#cookies).

#### start_urls(\*urls)

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

If `start_urls` is empty the crawler is still started once with a stub response
calling `parse`, which is handy when the first urls are computed in `parse`
itself:

```ruby
class MyScraper < Vessel::Cargo
  def parse
    (1..10).each do |page|
      yield request(url: "https://example.com/?page=#{page}")
    end
  end
end
```

`request` builds an absolute url in this case, the stub response has no url to
resolve a relative one against.

#### delay(value)

```ruby
class MyScraper < Vessel::Cargo
  delay 4..6
  threads max: 1
end
```

Number of seconds to keep between two consecutive requests, a range is sampled
randomly per request. `0` by default. The delay is only applied when the crawler
is single threaded, with a pool of more than one thread it doesn't make sense.

#### threads(min: 1, max: processor_count)

```ruby
class MyScraper < Vessel::Cargo
  threads min: 1, max: 5
end
```

`max` defaults to the number of the processors, the same pool size is used both
for fetching pages and for running the middleware.

#### network_error_attempts(value)

```ruby
class MyScraper < Vessel::Cargo
  network_error_attempts 3
end
```

How many times a url is retried when the driver raises a network error, e.g. a
timeout, a socket error or a bad status. The browser is restarted between the
attempts. Defaults to `5`. When the attempts are exhausted the error is passed
to the [`on_error`](/docs/vessel/callbacks#on_errorrequest-error) callback.
