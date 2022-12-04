# frozen_string_literal: true

require "spec_helper"

module Vessel
  describe Middleware do
    it "builds nothing" do
      expect(Middleware.build({ middleware: [] })).to eq(Middleware)
    end

    it "builds chain", skip: true do
      a = Class.new(Middleware)
      b = Class.new(Middleware)
      expect(Middleware.build({ middleware: [a.name, b.name] })).to eq(a.new(b.new))
    end
  end
end
