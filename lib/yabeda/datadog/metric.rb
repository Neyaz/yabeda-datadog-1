# frozen_string_literal: true

require "yabeda/datadog/units"

module Yabeda
  module Datadog
    # = Internal adapter representation of metrics
    class Metric
      def initialize(metric, type, overides = {})
        @metric = metric
        @type = type
        @overides = overides
      end

      # Datadog API argument
      def metadata
        {
          type: type,
          description: description,
          short_name: name,
          unit: unit,
          per_unit: per_unit,
        }
      end

      # Datadog API argument
      def name
        [metric.group, metric.name.to_s, overides[:name_sufix]].compact.join(".")
      end

      # Datadog API argument
      def description
        overides.fetch(:description, metric.comment)
      end

      # Datadog API argument
      def unit
        overides.fetch(:unit) do
          metric_unit = metric.unit
          metric_unit if metric_unit && UNITS.include?(metric_unit)
        end
      end

      # Datadog API argument
      def per_unit
        overides.fetch(:per_unit) do
          metric_per = metric.per
          metric_per if metric_per && UNITS.include?(metric_per)
        end
      end

      # Update metric metadata
      def update(api)
        api.update_metadata(name, metadata)
      end

      private

      attr_reader :metric, :type, :overides
    end
  end
end
