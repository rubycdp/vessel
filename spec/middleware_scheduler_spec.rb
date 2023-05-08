# frozen_string_literal: true

require "spec_helper"

module Vessel
  describe MiddlewareScheduler do
    it "builds no middlewares" do
      expect(MiddlewareScheduler.new({ middleware: [] }).middlewares).to eq([])
    end

    # rubocop:disable Lint/ConstantDefinitionInBlock
    it "builds chained middlewares" do
      MiddlewareA = Class.new(Middleware)
      MiddlewareB = Class.new(Middleware)
      executor = MiddlewareScheduler.new({ middleware: [MiddlewareA.name, MiddlewareB.name] })

      expect(executor.middlewares[0]).to be_a(MiddlewareA)
      expect(executor.middlewares[1]).to be_a(MiddlewareB)
    end
    # rubocop:enable Lint/ConstantDefinitionInBlock
  end
end
