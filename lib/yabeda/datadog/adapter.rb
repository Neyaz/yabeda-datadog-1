# frozen_string_literal: true

require "yabeda/base_adapter"
require 'datadog/statsd'

module Yabeda
  module Datadog
    # DataDog adapter. Sends yabeda metrics as custom metrics to DataDog API.
    # https://docs.datadoghq.com/integrations/ruby/
    class Adapter < BaseAdapter
      def register_counter!(counter)
        # TODO: implement
      end

      def perform_counter_increment!(counter, tags, increment)
        metric = Metric.new(counter, "counter")
        dog.increment(metric.name, by: increment, tags: tags)
      end

      def register_gauge!(gauge)
        # TODO: implement
      end

      def perform_gauge_set!(gauge, tags, value)
        metric = Metric.new(gauge, "gauge")
        dog.gauge(metric.name, value, tags: tags)
      end

      def register_histogram!(_metric)
        # TODO: implement
      end

      def perform_histogram_measure!(historam, tags, value)
        metric = Metric.new(historam, "histogram")
        dog.histogram(metric.name, value, tags: tags)
      end

      private

      def dog
        @dog ||= ::Datadog::Statsd.new(ENV["DATADOG_AGENT_HOST"], 8125)
      end

      Yabeda.register_adapter(:datadog, new)

      # Internal adapter representation of metrics
      class Metric
        def initialize(metric, type)
          @metric = metric
          @type = type
        end

        attr_reader :type

        def metadata
          {
            type: type,
            description: description,
            short_name: name,
            unit: unit,
            per_unit: per_unit,
          }
        end

        def name
          parts = ""
          parts += "#{metric.group}." if metric.group
          parts + metric.name.to_s
        end

        def description
          metric.comment
        end

        def unit
          metric.unit
        end

        def per_unit
          metric.per
        end

        private

        attr_reader :metric
      end
    end
  end
end
