# frozen_string_literal: true

module Vessel
  module Util
    def deep_clone(value)
      case value
      when Hash
        value.inject({}) { |b, (k, v)| b.merge(k => deep_clone(v)) }
      when Array
        value.inject([]) { |b, v| b << deep_clone(v) }
      else
        value
      end
    end
  end
end
