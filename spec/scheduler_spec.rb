# frozen_string_literal: true

require "spec_helper"

module Vessel
  describe Scheduler do
    let(:settings)  { Vessel::Cargo.settings }
    let(:queue)     { SizedQueue.new(settings[:max_threads]) }
    let(:scheduler) { Scheduler.new(queue, settings) }

    it 'has a queue' do
      expect( scheduler.queue ).to be(queue)
    end

		it 'has a browser' do
      expect( scheduler.browser ).to be_a(Ferrum::Browser)
    end

    describe '#post' do
      let(:request) { Vessel::Request.new } # empty request stub

      before { scheduler.post(request) }

      it 'schedules requests for execution' do
        expect( scheduler.queue.length ).to eq(0)

        sleep 1 # wait for execution

        expect( scheduler.queue.length ).to eq(1)
        expect( scheduler.queue.pop ).to eq([nil, request])
      end

      it 'updates thread pool statistics' do
        expect( scheduler.scheduled_task_count ).to eq(1)
        expect( scheduler.completed_task_count ).to eq(0)

        sleep 1 # wait for execution

        expect( scheduler.scheduled_task_count ).to eq(1)
        expect( scheduler.completed_task_count ).to eq(1)
      end
    end

  end
end
