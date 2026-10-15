---
sidebar_position: 4
---

# Requests

#### request(url:, \*\*options) : `Vessel::Request`

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

* options `Hash`
  * :url `String` absolute or relative url, resolved against the current page
  * :handler `Symbol` method to call with the response, `:parse` by default,
    `:callback` is an alias
  * :data `Hash` arbitrary data carried over to the response, deep-copied
  * :delay `Numeric` | `Range` overrides the crawler
    [delay](/docs/vessel/settings#delayvalue) for this request
  * :headers `Hash` overrides the crawler
    [headers](/docs/vessel/headers-cookies#headers) for this request
  * :cookies `Array<Hash>` overrides the crawler
    [cookies](/docs/vessel/headers-cookies#cookies) for this request
  * :once `Boolean` `true` by default, the same url is not visited twice, pass
    `false` to allow it
  * :encode `Boolean` `true` by default, the url is decoded and encoded again
    before it's joined

## Yielding

A handler can yield:

* a single request or an array of them, they're scheduled
* a `Hash` or [fields](/docs/vessel/fields), or an array of them, they go
  through the [middleware](/docs/vessel/middleware)

but not requests and items in one `yield`:

```ruby
def parse
  links = css("a.product").map { |a| request(url: a[:href], handler: :parse_product) }
  yield links

  yield({ title: at_css("h1").text })
end
```

## Visiting a url once

Every url is counted when the driver is about to fetch it, a request for an
already visited url is rejected and logged, its handler is not called. Pass `once: false` to fetch
the same url again, for example to poll it:

```ruby
yield request(url: url, handler: :parse_status, once: false)
```

## Errors

A request that keeps failing with a network error is retried up to
[`network_error_attempts`](/docs/vessel/settings#network_error_attemptsvalue)
times, then the request and the error are passed to
[`on_error`](/docs/vessel/callbacks#on_errorrequest-error). An error raised in
a handler is logged and doesn't stop the crawler.
