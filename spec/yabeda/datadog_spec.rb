# frozen_string_literal: true

RSpec.describe Yabeda::Datadog do
  it "has a version number" do
    expect(Yabeda::Datadog::VERSION).not_to be nil
  end

  describe "DataDog adapter" do
    let(:dog_client) { instance_double("Dogapi::Client") }

    before do
      Yabeda.configure do
        group :fake_dam

        counter :gate_opens
        gauge :water_level
      end

      allow(dog_client).to receive(:emit_point)
      allow(Dogapi::Client).to receive(:new).and_return(dog_client)
    end

    it "calls emit_point with an increment arguments" do
      Yabeda.fake_dam_gate_opens.increment(gate: :fake)
      expect(dog_client).to have_received(:emit_point).with("fake_dam.gate_opens", 1, type: "counter", gate: :fake)
    end

    it "calls emit_point with a gauge arguments" do
      Yabeda.fake_dam_water_level.set({}, 42)
      expect(dog_client).to have_received(:emit_point).with("fake_dam.water_level", 42, type: "gauge")
    end

    it "raise NotImplementedError when register histogram metric" do
      expect do
        Yabeda.histogram(:gate_throughput, unit: :cubic_meters, per: :gate_open, buckets: [1, 10, 100, 1_000, 10_000])
      end.to raise_error(NotImplementedError)
    end
  end
end
