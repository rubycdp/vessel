# frozen_string_literal: true

require "spec_helper"

module Vessel
  describe Middleware do
    it "builds nothing" do
      expect(Middleware.build).to be_nil
      expect(Middleware.build(*nil)).to be_nil

      args = []
      expect(Middleware.build(*args)).to be_nil
    end

    it "builds chain" do
      a = Class.new(Middleware)
      b = Class.new(Middleware)
      expect(Middleware.build(a, b)).to eq(a.new(b.new))
    end
  end
end
