# frozen_string_literal: true

require "yabeda/base_adapter"
require "datadog/statsd"
require "dogapi"

module Yabeda
  module Datadog
    DEFAULT_AGENT_HOST = "localhost"
    DEFAULT_AGENT_PORT = 8125

    # = DataDog adapter.
    #
    # Sends yabeda metrics as custom metrics to DataDog API.
    # https://docs.datadoghq.com/integrations/ruby/
    class Adapter < BaseAdapter
      def register_counter!(counter)
        metric = Metric.new(counter, "counter")
        Thread.new { dogapi.update_metadata(metric.name, metric.metadata) }
      end

      def perform_counter_increment!(counter, tags, increment)
        metric = Metric.new(counter, "counter")
        dogstatsd.count(metric.name, increment, tags: build_tags(tags))
      end

      def register_gauge!(gauge)
        metric = Metric.new(gauge, "gauge")
        Thread.new { dogapi.update_metadata(metric.name, metric.metadata) }
      end

      def perform_gauge_set!(gauge, tags, value)
        metric = Metric.new(gauge, "gauge")
        dogstatsd.gauge(metric.name, value, tags: build_tags(tags))
      end

      def register_histogram!(histogram)
        # sending many requests in separate threads
        # cause rejections by Datadog API
        Thread.new do
          build_histogram_metrics(histogram).map do |historgam_sub_metric|
            dogapi.update_metadata(historgam_sub_metric.name, historgam_sub_metric.metadata)
          end
        end
      end

      def perform_histogram_measure!(historam, tags, value)
        metric = Metric.new(historam, "histogram")
        dogstatsd.histogram(metric.name, value, tags: build_tags(tags))
      end

      private

      def dogstatsd
        # consider memoization here
        ::Datadog::Statsd.new(
          ENV.fetch("DATADOG_AGENT_HOST", DEFAULT_AGENT_HOST),
          ENV.fetch("DATADOG_AGENT_PORT", DEFAULT_AGENT_PORT),
        )
      end

      def dogapi
        # consider memoization here
        ::Dogapi::Client.new(ENV["DATADOG_API_KEY"], ENV["DATADOG_APP_KEY"])
      end

      def build_tags(tags)
        tags.map { |key, val| "#{key}:#{val}" }
      end

      def build_histogram_metrics(historgram)
        [
          Metric.new(historgram, "gauge", name_sufix: "avg"),
          Metric.new(historgram, "rate", name_sufix: "count", unit: nil, per_unit: nil),
          Metric.new(historgram, "gauge", name_sufix: "median"),
          Metric.new(historgram, "gauge", name_sufix: "95percentile", unit: nil, per_unit: nil),
          Metric.new(historgram, "gauge", name_sufix: "max"),
          Metric.new(historgram, "gauge", name_sufix: "min"),
        ]
      end

      # = Internal adapter representation of metrics
      class Metric
        def initialize(metric, type, overides = {})
          @metric = metric
          @type = type
          @overides = overides
        end

        # TODO: consider to make private
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
          [metric.group, metric.name.to_s, overides[:name_sufix]].compact.join(".")
        end

        def description
          overides.fetch(:description, metric.comment)
        end

        def unit
          overides.fetch(:unit, metric.unit)
        end

        def per_unit
          overides.fetch(:per_unit, metric.per)
        end

        private

        attr_reader :metric, :overides
      end

      Yabeda.register_adapter(:datadog, new)
    end
  end
end
