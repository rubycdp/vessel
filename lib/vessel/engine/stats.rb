# frozen_string_literal: true

module Vessel
  class Engine
    module Stats
      private

      def stats
        {
          req_enqueued: req_enqueued.value, res_dequeued: res_dequeued.value,
          res_handled: res_handled.value, item_pipelined: item_pipelined.value,
          item_processed: item_processed.value, item_sent: item_sent.value,
          item_rejected: item_rejected.value, idling: idle?
        }
      end

      def increase(name)
        send(name).increment
        @crawler_class.new.after_change(name, stats)
      end

      def req_enqueued
        @req_enqueued ||= Concurrent::AtomicFixnum.new
      end

      def res_dequeued
        @res_dequeued ||= Concurrent::AtomicFixnum.new
      end

      def res_handled
        @res_handled ||= Concurrent::AtomicFixnum.new
      end

      def item_pipelined
        @item_pipelined ||= Concurrent::AtomicFixnum.new
      end

      def item_processed
        @item_processed ||= Concurrent::AtomicFixnum.new
      end

      def item_sent
        @item_sent ||= Concurrent::AtomicFixnum.new
      end

      def item_rejected
        @item_rejected ||= Concurrent::AtomicFixnum.new
      end
    end
  end
end
