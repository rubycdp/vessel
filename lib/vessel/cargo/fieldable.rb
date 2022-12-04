# frozen_string_literal: true

require "vessel/cargo/field"
require "vessel/cargo/field_type"
require "vessel/cargo/fields"

module Vessel
  class Cargo
    module Fieldable
      def fields
        @fields ||= Fields.new
      end

      def field(name, *rest, &block)
        options = rest.last.is_a?(Hash) ? rest.pop : {}
        service = options.delete(:service)
        field = Field.new(name: name, value: options[:value], context: self, **options, &block)
        value = field.apply
        if service
          fields.service[name.to_sym] = value
        else
          fields[field.name] = value
        end
      end
    end
  end
end
