# frozen_string_literal: true

require "dogapi"
require "yabeda/base_adapter"

module Yabeda
  module Datadog
    # DataDog adapter. Sends yabeda metrics as custom metrics to DataDog API.
    # https://docs.datadoghq.com/integrations/ruby/
    class Adapter < BaseAdapter
      def register_counter!(_metric)
        # Do nothing. DataDog don't need to register metrics
      end

      def perform_counter_increment!(counter, tags, increment)
        tags[:type] = "counter"
        metric = AdapterMetric.new(counter)
        dog.emit_point(metric.name, increment, tags)
      end

      def register_gauge!(_metric)
        # Do nothing. DataDog don't need to register metrics
      end

      def perform_gauge_set!(gauge, tags, value)
        tags[:type] = "gauge"
        metric = AdapterMetric.new(gauge)
        dog.emit_point(metric.name, value, tags)
      end

      private

      def dog
        ::Dogapi::Client.new(ENV["DATADOG_API_KEY"])
      end

      Yabeda.register_adapter(:datadog, new)
    end

    # Internal adapter representation of metrics
    class AdapterMetric
      def initialize(metric)
        @metric = metric
      end

      def name
        parts = ""
        parts += metric.group.to_s if metric.group
        parts + ".#{metric.name}"
      end

      private

      attr_reader :metric
    end
  end
end
