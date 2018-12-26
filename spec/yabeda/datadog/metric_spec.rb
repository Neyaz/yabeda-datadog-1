# frozen_string_literal: true

RSpec.describe Yabeda::Datadog::Metric do
  describe "#unit" do
    it "returns only allowed metrics" do
      metric = instance_double("Yabeda::Counter", name: "some_service.some.some_counter", unit: "second")
      datadog_metric = described_class.new(metric, "counter")
      expect(datadog_metric.unit).to eq("second")
    end

    it "returns nil for metrics that not allowed" do
      metric = instance_double("Yabeda::Counter", name: "some_service.some.some_counter", unit: "super-second")
      datadog_metric = described_class.new(metric, "counter")
      expect(datadog_metric.unit).to be_nil
    end

    it "ingores metric.unit and returns overided value if present" do
      metric = instance_double("Yabeda::Counter", name: "some_service.some.some_counter", unit: "second")
      datadog_metric = described_class.new(metric, "counter", unit: "millisecond")
      expect(datadog_metric.unit).to eq("millisecond")
    end
  end

  describe "#per_unit" do
    it "returns only allowed metrics" do
      metric = instance_double("Yabeda::Counter", name: "some_service.some.some_counter", per: "second")
      datadog_metric = described_class.new(metric, "counter")
      expect(datadog_metric.per_unit).to eq("second")
    end

    it "returns nil for metrics that not allowed" do
      metric = instance_double("Yabeda::Counter", name: "some_service.some.some_counter", per: "super-second")
      datadog_metric = described_class.new(metric, "counter")
      expect(datadog_metric.per_unit).to be_nil
    end

    it "ingores metric.per_unit and returns overided value if present" do
      metric = instance_double("Yabeda::Counter", name: "some_service.some.some_counter", per: "second")
      datadog_metric = described_class.new(metric, "counter", per_unit: "millisecond")
      expect(datadog_metric.per_unit).to eq("millisecond")
    end
  end
end
