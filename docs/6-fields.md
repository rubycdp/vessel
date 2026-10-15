---
sidebar_position: 6
---

# Fields

Instead of building a hash by hand a handler can declare fields and yield the
collected `fields` object.

#### field(name, \*\*options, &block)

* options `Hash`
  * :value `Object` value of the field
  * :service `Boolean` keeps the field out of the resulting hash, it's only
    available as `fields.service[:name]` in the
    [middleware](/docs/vessel/middleware)
  * :rename `Hash` stores the field under another name, e.g.
    `{ "author" => :writer }`
  * :typing `Boolean` `false` skips the [field type](#field-types)
* block - called instead of `value` when it's given

#### fields : `Vessel::Cargo::Fields`

Fields collected in the handler, `fields.to_h` returns them as a `Hash`.

```ruby
class MyScraper < Vessel::Cargo
  def parse
    field :author, value: at_xpath("span/small").text
    field :text, value: at_css("span.text").text
    field :html, value: nil, service: true do
      raw
    end

    yield fields
  end
end
```

The middleware gets `{ author: ..., text: ... }` as the hash and the fields
object with `fields.service[:html]`.

## Field types

Fields can be normalized in one place by their name. Put such declarations into
`config/fields` of a [generated project](/docs/vessel/projects-cli):

```ruby
Vessel::Cargo::FieldType.add(:price) { |value| value.to_s.gsub(/[^\d.]/, "").to_f }
Vessel::Cargo::FieldType.add(:title, :name) { |value| value.to_s.strip }
```

Every `field :price` is then passed through that block, `typing: false` skips
it. The type is looked up by the final name, after `rename`. The block is
evaluated in the crawler instance, so `url`, `data` and the selectors are
available in it.
