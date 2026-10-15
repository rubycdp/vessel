---
sidebar_position: 7
---

# Middleware

Everything a handler yields that is not a request goes through the middleware
pipeline, which runs in its own thread pool.

#### middleware(\*names)

Sets the pipeline by class names.

A middleware is a `Vessel::Middleware` subclass with a `call(hash, fields)`
method, it gets the hash returned by the previous middleware plus the original
[fields](/docs/vessel/fields) object, and returns the hash for the next one:

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
project, the crawler settings are available as `settings`. A yielded `Hash` is
passed as `fields` too, so only use `fields.service` when the handler yields
fields.

## Rejecting items

Raising `Vessel::Middleware::InvalidItemError` silently rejects the item, any
other error is logged and counted as a rejection too. Both are counted in
`item_rejected` of the [stats](/docs/vessel/callbacks#stats).

## Block

A block passed to `.run` replaces the whole pipeline, which is the shortest way
to collect the items in a script:

```ruby
quotes = []
QuotesToScrapeCom.run { |item| quotes << item }
```

The block is called with the same `hash` and `fields` arguments.

Items are processed concurrently, so a shared object like `quotes` above must be
safe to use from many threads, or set `threads max: 1`.
