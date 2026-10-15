---
sidebar_position: 5
---

# Selectors

The response is delegated to the crawler, so inside a handler you can call the
following methods directly.

#### css(selector) : `Array<Node>`

#### at_css(selector) : `Node` | `nil`

#### xpath(selector) : `Array<Node>`

#### at_xpath(selector) : `Node` | `nil`

Search the page.

```ruby
def parse
  css("div.quote").each do |quote|
    puts quote.at_css("span.text").text
  end
  puts at_xpath("//title").text
end
```

#### url : `Addressable::URI`

Url of the current page.

#### data : `Hash`

Data attached to the [request](/docs/vessel/requests).

#### attempt : `Integer`

Which attempt it is to load the page.

#### size : `Integer`

Page size in bytes.

#### body : `Nokogiri::HTML::Document`

Nokogiri document of the page html.

#### raw : `String`

Raw html of the page.

#### absolute_url(relative, encode: true) : `String`

Resolves a url against the current page.

```ruby
absolute_url("/page/2/") # => "https://quotes.toscrape.com/page/2/"
```

#### join_url(head, tail) : `String`

Joins two urls.

#### url_encode(url) : `String`

#### url_decode(url) : `String`

Encode or decode a url, aliased as `uri_encode` and `uri_decode`.

## Response

`response` and `page` are available in a handler as well, `page` being the
driver's native object, `Ferrum::Page` or `Mechanize::Page`.

* `response.status` - response status
* `response.headers` - request headers of the page
* `response.handler` - handler of the request
* `response.sync_body(seconds = 2)` - re-reads the html after a pause when the
  page needs a moment to render

```ruby
def parse
  return if response.status != 200

  page.at_css("button.more").click
  response.sync_body
end
```

## Page snapshot

By default the selectors run against the live page, which for the Ferrum driver
means Chrome does the querying. Setting `Vessel.page_snapshot = true` makes them
run against the Nokogiri document of the page's html instead, which is much
faster when you extract a lot of nodes and don't need to interact with the page.

```ruby
Vessel.page_snapshot = true
```

Keep in mind that the nodes you get back come from the driver, `Ferrum::Node` or
`Nokogiri::XML::Node`, and the two don't have the same api. Read the attributes
with `node[:href]`, that one works everywhere, `node.attribute(:href)` only works
on the live Chrome page.
