# frozen_string_literal: true

RSpec.describe Yabeda::Datadog::Worker do
  let(:num_threads) { described_class::NUM_THREADS }

  describe "::start" do
    it "create an instance an spawns it's treads" do
      worker = instance_spy("Yabeda::Datadog::Worker")
      allow(described_class).to receive(:new).and_return(worker)

      instance = described_class.start

      expect(instance).to eq(worker)
      expect(worker).to have_received(:spawn_threads).with(num_threads)
    end
  end

  describe "#enqueue" do
    let(:queue) { [] }
    let(:worker) { described_class.new(queue) }

    it "adds action and payload to queue" do
      worker.enqueue(:send, data: 1)
      expect(queue).to include([:send, { data: 1 }])
    end
  end

  describe "#spawn_threads" do
    let(:queue) { [] }
    let(:worker) { described_class.new(queue) }

    it "spawns given number of therads" do
      allow(Thread).to receive(:new)
      worker.spawn_threads(5)
      expect(Thread).to have_received(:new).exactly(5).times
    end

    it "dispatches enqueued actions" do
      allow(described_class::ACTIONS[:send]).to receive(:call)
      allow(described_class::ACTIONS[:register]).to receive(:call)
      worker.enqueue(:send, a: 1)
      worker.enqueue(:send, b: 2)
      worker.enqueue(:register, name: :a)

      worker.spawn_threads(1)
      sleep(0.1)

      expect(described_class::ACTIONS[:send]).to have_received(:call).with(a: 1)
      expect(described_class::ACTIONS[:send]).to have_received(:call).with(b: 2)
      expect(described_class::ACTIONS[:register]).to have_received(:call).with(name: :a)
    end

    it "returns true" do
      expect(worker.spawn_threads(0)).to eq(true)
    end
  end

  describe "#stop" do
    let(:queue) { [] }
    let(:worker) { described_class.new(queue) }
    let(:fake_thread) { instance_spy("Thread") }

    it "empties worker's queue" do
      worker.enqueue(:send, {})
      worker.enqueue(:register, {})
      expect(queue).not_to be_empty
      worker.stop
      expect(queue).to be_empty
    end

    it "terminates all threads" do
      allow(Thread).to receive(:new).and_return(fake_thread)
      worker.spawn_threads(4)
      worker.stop
      expect(fake_thread).to have_received(:exit).exactly(4).times
    end

    it "empties treads list" do
      worker.spawn_threads(4)
      expect(worker.spawned_threads_count).to eq(4)
      worker.stop
      expect(worker.spawned_threads_count).to eq(0)
    end

    it "returns true" do
      expect(worker.stop).to eq(true)
    end
  end
end
