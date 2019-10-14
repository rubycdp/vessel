# frozen_string_literal: true

require "spec_helper"

module Vessel
  describe Middleware do
    it "builds nothing" do
      expect(Middleware.build).to be_nil
      expect(Middleware.build(*nil)).to be_nil
      expect(Middleware.build(*[])).to be_nil
    end

    it "builds chain" do
      A = Class.new(Middleware)
      B = Class.new(Middleware)
      expect(Middleware.build(A, B)).to eq(A.new(B.new))
    end
  end
end
