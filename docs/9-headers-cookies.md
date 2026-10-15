---
sidebar_position: 9
---

# Headers & Cookies

## Headers

#### headers(value)

Sets headers sent with every request.

```ruby
class MyScraper < Vessel::Cargo
  headers "User-Agent" => "Vessel",
          "Referer" => "https://example.com"
end
```

A [request](/docs/vessel/requests) can override them with `headers:`. The
`:mechanize` driver takes its user agent from the `"User-Agent"` key.

## Cookies

#### cookie(name:, value:, \*\*options)

Sets one cookie.

* options `Hash`
  * :domain `String` the crawler [domain](/docs/vessel/settings#domainvalue) by
    default
  * :path `String`
  * :httponly `Boolean`
  * :secure `Boolean`
  * :expires `Time` | `Integer`

#### cookies(\*cookies)

Sets an array of cookies, each one takes the same keys as `cookie`.

```ruby
class MyScraper < Vessel::Cargo
  domain "example.com"

  cookie name: "lang", value: "en", path: "/"
  cookies [
    { name: "session", value: "abc", domain: "example.com", path: "/" },
    { name: "consent", value: "1", path: "/", secure: true }
  ]
end
```

A [request](/docs/vessel/requests) can override them with `cookies:`.

#### allow_cookies(value)

By default cookies collected from a response replace the crawler cookies and are
sent with the following requests, so a session started on one page is kept for
the next ones. `allow_cookies false` turns that off.

```ruby
class MyScraper < Vessel::Cargo
  allow_cookies false
end
```
