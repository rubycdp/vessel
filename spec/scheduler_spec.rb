# frozen_string_literal: true

require "spec_helper"

module Vessel
  describe Scheduler do
    let(:settings)  { Vessel::Cargo.settings }
    let(:queue)     { SizedQueue.new(settings[:max_threads]) }
    let(:scheduler) { Scheduler.new(queue, settings) }

    it "has a queue" do
      expect(scheduler.queue).to be(queue)
    end

		it "has a driver" do
      expect( scheduler.driver ).to be_a(Vessel::Driver)
    end

    it "has thread pool statistics" do
      expect(scheduler.scheduled_task_count).to eq(0)
      expect(scheduler.completed_task_count).to eq(0)
      expect(scheduler.queue_length).to eq(0)
    end

    describe "#post" do
      let(:request) { Vessel::Request.new } # empty request stub

      before { scheduler.post(request) }

      it "schedules requests for execution" do
        expect(scheduler.queue.length).to eq(0)

        sleep 1 # wait for execution

        expect(scheduler.queue.length).to eq(1)
        expect(scheduler.queue.pop).to eq([nil, request])
      end

      it "updates thread pool statistics" do
        expect(scheduler.scheduled_task_count).to eq(1)
        expect(scheduler.completed_task_count).to eq(0)

        sleep 1 # wait for execution

        expect(scheduler.scheduled_task_count).to eq(1)
        expect(scheduler.completed_task_count).to eq(1)
      end
    end

    describe "#stop" do
      let(:driver) { spy("Vessel::Driver") }
      let(:pool) { spy("ThreadPoolExecutor") }

      before do
        scheduler.instance_variable_set(:@driver, driver)
        scheduler.instance_variable_set(:@pool, pool)
      end

      it "attempts to shut down the thread pool" do
        scheduler.stop

        expect(pool).to have_received(:shutdown)
        expect(pool).not_to have_received(:kill)
      end

      it "kills the thread pool if necessary" do
        allow(pool).to receive(:wait_for_termination).and_return(false)

        scheduler.stop

        expect(pool).to have_received(:shutdown)
        expect(pool).to have_received(:kill)
      end

      it "quits the browser" do
        scheduler.stop

        expect(scheduler.driver).to have_receive(:stop)
      end
    end

  end
end
