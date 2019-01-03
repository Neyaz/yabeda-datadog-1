# frozen_string_literal: true

require "yabeda"
require "yabeda/datadog/adapter"
require "yabeda/datadog/version"
require "yabeda/datadog/logger"

module Yabeda
  # = Namespace for DataDog adapter
  module Datadog
    SECOND = 1
    COLLECT_INTERVAL = 60 * SECOND

    # TODO: consider to change too manual
    def self.start
      adapter = Yabeda::Datadog::Adapter.new
      Yabeda.register_adapter(:datadog, adapter)
      adapter
    end

    def self.start_exporter(collect_interval: COLLECT_INTERVAL)
      Thread.new do
        Logger.instance.info "initilize collectors harvest"
        loop do
          Logger.instance.info "start collectors harvest"
          Yabeda.collectors.each(&:call)
          Logger.instance.info "end collectors harvest"
          sleep(collect_interval)
        end
      end
    end
  end
end
