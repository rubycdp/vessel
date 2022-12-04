# frozen_string_literal: true

module Vessel
  class Cargo
    class FieldType
      class << self
        def add(*names, &block)
          names.each { |n| types.merge!(n.to_sym => block) }
        end

        def types
          @types ||= {}
        end
      end
    end
  end
end
