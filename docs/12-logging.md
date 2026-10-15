---
sidebar_position: 12
---

# Logging

Vessel logs to `$stdout` at the debug level. Pass your own logger to change
that:

```ruby
Vessel::Logger.instance = Logger.new("log/vessel.log", level: Logger::INFO)
```

Any object responding to `debug`, `info`, `warn` and `error` works. Use it from
your crawler or middleware as well:

```ruby
Vessel::Logger.info("Saved #{hash[:title]}")
```

At the debug level Vessel logs every scheduled request and every handler call,
at the info level the visited urls and the [stats](/docs/vessel/callbacks#stats)
every 4 seconds, at the error level network issues and errors raised in the
handlers and the middleware.

To see what the browser does pass `FERRUM_DEBUG=true` or a `logger` to the
[driver](/docs/vessel/drivers):

```ruby
class MyScraper < Vessel::Cargo
  driver :ferrum, logger: $stderr
end
```
