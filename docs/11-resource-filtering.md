---
sidebar_position: 11
---

# Resource filtering

#### blacklist(patterns)

Blocks resources matching any of the patterns.

#### whitelist(patterns)

Allows only resources matching any of the patterns.

Patterns of the resources Chrome is allowed to load, useful to skip images,
fonts or trackers and speed the crawler up:

```ruby
class MyScraper < Vessel::Cargo
  blacklist [/\.png$/, /googletagmanager/]
  # or
  whitelist [/example.com/]
end
```

Patterns are regular expressions matched against the requested urls, see
Ferrum's [Network](/docs/ferrum/network).

Ferrum driver only, the `:mechanize` driver doesn't load resources and prints a
warning when they are set.
