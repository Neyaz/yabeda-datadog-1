# frozen_string_literal: true

module Yabeda
  module Datadog
    # = Internal adapter representation of metrics
    class Metric
      def initialize(metric, type, overides = {})
        @metric = metric
        @type = type
        @overides = overides
      end

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

      def update(api)
        api.update_metadata(name, metadata)
      end

      private

      attr_reader :metric, :type, :overides
    end
  end
end
