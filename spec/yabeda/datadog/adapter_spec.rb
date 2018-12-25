# frozen_string_literal: true

RSpec.describe Yabeda::Datadog::Adapter do
  describe "dogapi integration" do
    it "expects Dogapi::Client to respond to new" do
      expect(Dogapi::Client).to respond_to(:new)
    end
  end

  describe "dogstatsd integration" do
    it "expects Datadog::Statsd to respond to new" do
      expect(Datadog::Statsd).to respond_to(:new)
    end
  end

  describe "update metadata" do
    let(:dog_client) { instance_double("Dogapi::Client") }

    before do
      allow(dog_client).to receive(:update_metadata)
      allow(::Dogapi::Client).to receive(:new).and_return(dog_client)
    end

    it "calls dogapi update_metadata with counter metric", fake_thread: true do
      Yabeda.counter(:gate_opens, comment: "gate_opens description")
      expected_kwargs = { description: "gate_opens description", short_name: "gate_opens",
                          type: "counter", per_unit: nil, unit: nil, }
      expect(dog_client).to have_received(:update_metadata).with("gate_opens", expected_kwargs)
    end

    it "calls dogapi update_metadata with gauge metric", fake_thread: true do
      Yabeda.gauge(:water_level, unit: "Ml", per: "???")
      expected_kwargs = { description: nil, short_name: "water_level",
                          type: "gauge", per_unit: "???", unit: "Ml", }
      expect(dog_client).to have_received(:update_metadata).with("water_level", expected_kwargs)
    end

    it "calls dogapi update_metadata with histogram metric", fake_thread: true do
      Yabeda.histogram(:gate_throughput, unit: "cubic_meters", per: "gate_open", buckets: [1, 10, 100, 1_000, 10_000])
      expected_kwargs = { description: nil, short_name: "gate_throughput",
                          type: "histogram", per_unit: "gate_open", unit: "cubic_meters", }
      expect(dog_client).to have_received(:update_metadata).with("gate_throughput", expected_kwargs)
    end
  end

  describe "custom metrics" do
    let(:dog_client) { instance_double("dogapi::client") }
    let(:dogstatsd) { instance_double("datadog::statsd") }

    before do
      allow(dog_client).to receive(:update_metadata)
      allow(Dogapi::Client).to receive(:new).and_return(dog_client)

      allow(Datadog::Statsd).to receive(:new).and_return(dogstatsd)
      allow(dogstatsd).to receive(:count)
      allow(dogstatsd).to receive(:gauge)
      allow(dogstatsd).to receive(:histogram)

      Yabeda.configure do
        group :fake_dam

        counter :gate_opens
        gauge :water_level
        histogram :gate_throughput, unit: :cubic_meters, per: :gate_open, buckets: [1, 10, 100, 1_000, 10_000]
      end
    end

    it "sends counter metric to dogstats-d", fake_thread: true do
      Yabeda.fake_dam_gate_opens.increment(gate: 1, success: true)
      expect(dogstatsd).to have_received(:count).with("fake_dam.gate_opens", 1, tags: ["gate:1", "success:true"])
    end

    it "sends gauge metric to dogstats-d", fake_thread: true do
      Yabeda.fake_dam_water_level.set({}, 42)
      expect(dogstatsd).to have_received(:gauge).with("fake_dam.water_level", 42, tags: [])
    end

    it "sends histogram metric to dogstats-d", fake_thread: true do
      Yabeda.fake_dam_gate_throughput.measure({ gate: 1 }, 4321)
      expect(dogstatsd).to have_received(:histogram).with("fake_dam.gate_throughput", 4321, tags: ["gate:1"])
    end
  end
end
