# frozen_string_literal: true

class Debug < Vessel::Middleware
  def call(hash, _fields)
    puts deep_sort(hash)
    hash
  end

  private

  def deep_sort(hash)
    sorted = hash.sort.to_h
    sorted.transform_values { |v| v.is_a?(Hash) ? deep_sort(v) : v }
  end
end
