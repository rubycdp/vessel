---
sidebar_position: 13
---

# Projects & CLI

A single-file script is enough for a small crawler, for a bigger one Vessel can
generate a project:

```shell
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
the settings can differ between development and production. `VESSEL_ENV`
selects the environment and defaults to `dev`. Both environments use the `Debug`
middleware which prints every item, replace it with your own.

`vessel generate example.com` creates `crawlers/example.com.rb`:

```ruby
class ExampleCom < ApplicationCrawler
  domain "example.com"
  start_urls "https://example.com"

  def parse
  end
end
```

The crawler is found by its [domain](/docs/vessel/settings#domainvalue), so keep
the file name and the domain the same.

## Commands

| Command | Description |
| --- | --- |
| `vessel new NAME` | Generate a new project |
| `vessel generate DOMAIN` | Generate `crawlers/DOMAIN.rb` |
| `vessel list` | List the crawlers of the project |
| `vessel settings DOMAIN` | Show the settings of a crawler |
| `vessel start DOMAIN` | Run a crawler |
| `vessel parse DOMAIN URL HANDLER --data=key:value` | Fetch one url and call one handler, for debugging |
| `vessel version` | Print the version |

`vessel parse` fetches a single url and calls a single handler without the
callbacks, the requests the handler yields are crawled as usual:

```shell
$ vessel parse quotes.toscrape.com https://quotes.toscrape.com/page/2/ parse --data=tag:humor
```

## Booting a project from Ruby

`Vessel.boot` loads `config/boot.rb` of the current directory, so you can run a
crawler from a script or a job:

```ruby
require "vessel"

Vessel.boot
Vessel.loader.load_crawler("example.com")
Vessel.loader.find_crawler("example.com").run
```

`config/boot.rb` sets `Vessel.loader` to `ApplicationLoader` from
`lib/loader.rb`, subclass `Vessel::Loader` there to change how crawlers are
found.
