---
sidebar_position: 10
---

# Proxy

#### proxy(klass)

Sets the proxy rotation class, the driver takes the next proxy for every page it
creates.

Subclass `Vessel::RoundRobinProxy` (or `Vessel::ShuffledProxy` to shuffle the
list on start) and define the `PROXIES` constant:

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

With the `:ferrum` driver every proxied page gets its own browser context, see
Ferrum's [Proxy](/docs/ferrum/proxy). With the `:mechanize` driver the proxy is
set on the Mechanize agent of the page.

## Custom rotation

For a fully custom rotation subclass `Vessel::Proxy` and implement `prepare`,
which is called once and fills in `@proxies`:

```ruby
class ApiProxy < Vessel::Proxy
  def prepare
    @proxies = ProxyProvider.fetch.map do |p|
      { host: p.ip, port: p.port, user: p.login, password: p.password }
    end
  end
end
```

Proxies are taken one by one in order. When the list is empty pages are created
without a proxy.
