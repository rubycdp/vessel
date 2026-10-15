---
sidebar_position: 3
---

# Drivers

#### driver(name, \*\*options)

Sets the driver to fetch pages with and its options.

```ruby
class MyScraper < Vessel::Cargo
  driver :ferrum, headless: true, timeout: 30
end
```

Two drivers ship with Vessel and are loaded the first time a crawler asks for
them. An unknown driver or a missing driver gem raises
`Vessel::DriverNotFoundError` with the gem to install.

## Ferrum

`:ferrum` is the default driver. It loads pages in a real Chrome driven by
[Ferrum](/docs/ferrum/introduction), so JavaScript is executed and the page is
rendered before your handler is called. Options are passed to
`Ferrum::Browser.new`, see [Ferrum customization](/docs/ferrum/customization).

Vessel changes a few Ferrum defaults:

* `timeout: 60`
* `js_errors: false`
* `process_timeout: 30`
* `pending_connection_errors: false`
* `browser_options: { "ignore-certificate-errors" => nil }`

Passing `browser_options` replaces the default ones, so add
`"ignore-certificate-errors" => nil` yourself if you need it.

You can disable headless mode by passing driver options at runtime:

```ruby
MyScraper.run(driver_options: { headless: false })
```

Every page is created in the same browser, a page with a
[proxy](/docs/vessel/proxy) gets its own browser context that is disposed when
the page is closed. `Ferrum::TimeoutError` and `Ferrum::StatusError` are
retried as [network errors](/docs/vessel/settings#network_error_attemptsvalue).

## Mechanize

`:mechanize` makes plain HTTP requests via
[Mechanize](https://github.com/sparklemotion/mechanize), no browser and no
JavaScript, which makes it much faster and lighter. The gem is not installed
with Vessel, add `gem "mechanize"` to your `Gemfile` to use this driver.

```ruby
class MyScraper < Vessel::Cargo
  driver :mechanize
end
```

* The user agent is taken from the `"User-Agent"` key of
  [headers](/docs/vessel/headers-cookies#headers).
* [blacklist and whitelist](/docs/vessel/resource-filtering) are not supported,
  a warning is printed when they are set.
* An error status is raised rather than parsed, so a `404` or a `500` is retried
  and ends up in [`on_error`](/docs/vessel/callbacks#on_errorrequest-error)
  instead of reaching your handler with `response.status` set.

## Custom driver

Subclass `Vessel::Driver`, implement `start`, `stop` and `create_page`, and
register it with `driver_name`:

```ruby
class HttpDriver < Vessel::Driver
  driver_name :http

  def start
    @client = MyHttpClient.new(**settings[:driver_options])
  end

  def stop
    @client&.close
  end

  def create_page(proxy: nil)
    HttpPage.new(@client, proxy: proxy)
  end
end

class MyScraper < Vessel::Cargo
  driver :http
end
```

`create_page` returns a `Vessel::Driver::Page` subclass implementing:

| Method | Description |
| --- | --- |
| `go_to(url)` | Loads the url, raises on a network error |
| `close` | Releases the page |
| `body` | Html of the page |
| `status` | Response status |
| `headers` / `headers=(hash)` | Request headers |
| `cookies` / `cookies=(array)` | Cookies, returned objects respond to `name`, `value`, `domain`, `path`, `httponly?`, `secure?` and `expires` |
| `size` | Page size in bytes |
| `current_url` | Url of the page |
| `blacklist=` / `whitelist=` | [Resource filtering](/docs/vessel/resource-filtering) |
| `page` | Native object answering `css`, `at_css`, `xpath` and `at_xpath` |

Without a native object to query set
[`Vessel.page_snapshot = true`](/docs/vessel/selectors#page-snapshot) so the
selectors run against the html.

Override `self.direct_network_errors` to list the errors that should be
[retried](/docs/vessel/settings#network_error_attemptsvalue), or
`self.indirect_network_errors` when the network error is the `cause` of the
raised one:

```ruby
class HttpDriver < Vessel::Driver
  def self.direct_network_errors
    @direct_network_errors ||= (super + [MyHttpClient::TimeoutError]).freeze
  end
end
```
