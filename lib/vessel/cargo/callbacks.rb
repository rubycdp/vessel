# frozen_string_literal: true

module Vessel
  class Cargo
    module Callbacks
      INFO_INTERVAL = 4

      def before_start; end

      def before(_stats); end

      def after_change(_counter, _stats); end

      def info(stats)
        Vessel::Logger.info "Cargo: #{stats.map { |k, v| "#{k}=#{v}" }.join(', ')}"
      end

      def after(_stats); end

      def before_stop; end

      def on_error(_request, error)
        raise error
      end
    end
  end
end
