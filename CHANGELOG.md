# Changelog

## 0.3.0 (unreleased)

The first release since 2021, the internals were rewritten along the way.

### Breaking

* Middleware is a class with a `call(hash, fields)` method now and is declared by
  its name, `middleware "Debug", "Save"`. The `Middleware.build` chain of the
  previous release is gone.
* `timeout` and `ferrum` settings are replaced by `driver`, e.g.
  `driver :ferrum, timeout: 30`.
* `intercept` is replaced by `blacklist` and `whitelist`.
* Urls are visited only once by default, pass `once: false` to a request to
  visit one again.

### Added

* Pluggable drivers, `:ferrum` (default, real Chrome) and `:mechanize` (plain
  HTTP, no browser), plus a `Vessel::Driver` base class for your own.
* Fields api, `field :name, value: ...` with blocks, `service: true`, `rename:`
  and `Vessel::Cargo::FieldType` for per name normalization.
* Requests carry `data`, and accept per request `handler`, `headers`, `cookies`,
  `delay` and `once`.
* `start_urls` accepts a hash of `url => handler`.
* Cookies, `cookie`/`cookies` to set them and `allow_cookies` to control whether
  the ones a page sends back are kept for the next requests.
* Proxy rotation, `Vessel::RoundRobinProxy` and `Vessel::ShuffledProxy`.
* Retries of the requests that fail with a network error,
  `network_error_attempts`.
* Callbacks, `before_start`, `before`, `after_change`, `info`, `after`,
  `before_stop` and `on_error`.
* `Vessel.page_snapshot` to run the selectors against a Nokogiri document
  instead of the live page.
* CLI and a project skeleton, `vessel new`, `generate`, `list`, `settings`,
  `start`, `parse` and `version`.
* `Vessel::Cargo` is the crawler base class, `Vessel::Crawler` is kept as an
  alias.

### Fixed

* The stats timer task is shut down when a run finishes, it used to keep logging
  and hold a thread for the life of the process ([#36](https://github.com/rubycdp/vessel/issues/36)).
* An url is registered before its page is opened, threads racing for the same
  url no longer visit it in parallel.
* The skeleton of a new project is packaged completely, `vessel new` used to
  generate a project without `crawlers`, `log`, `config/fields` and
  `lib/helpers` when Vessel was installed as a gem
  ([#37](https://github.com/rubycdp/vessel/issues/37)).
* The middleware and the settings of a generated project, `Debug` took one
  argument where the pipeline passes two and the prod environment called
  `thread` instead of `threads`.
* The templator closes the file it writes a crawler to.
* Settings are deep cloned into the subclasses of a crawler.
* The engine is idle only when every scheduled request and item is done.
* Ferrum 0.15 and up with a proxy.

### Changed

* Minimum Ruby is 3.1, the same as Ferrum.
* Dependencies are up to date, Ferrum 0.18, Mechanize 2.14, Nokogiri 1.18 and
  Thor 1.5. Addressable and concurrent-ruby are declared explicitly, they are
  required directly and used to come in through Ferrum.

## 0.2.0 (2021-03-09)

* Initial public releases, see the git history for the details.
