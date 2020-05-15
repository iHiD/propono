module Propono

  class ProponoConfigurationError < ProponoError
  end

  class Configuration

    def self.add_setting(sym, required: true)
      define_method(sym) do
        required ? get_or_raise(sym) : @settings[sym]
      end

      define_method("#{sym}=") do |new_value|
        @settings[sym] = new_value
      end
    end

    add_setting :aws_options
    add_setting :sqs_options
    add_setting :sns_options
    add_setting :application_name
    add_setting :logger
    add_setting :max_retries
    add_setting :num_messages_per_poll
    add_setting :slow_queue_enabled, required: false
    add_setting :queue_suffix, required: false

    def initialize
      @settings = {
        aws_options:           {},
        sqs_options:           {},
        sns_options:           {},
        logger:                Propono::Logger.new,
        queue_suffix:          "",
        max_retries:           0,
        num_messages_per_poll: 1,
        slow_queue_enabled:    true
      }
    end

    private

    def get_or_raise(setting)
      @settings[setting] || raise(ProponoConfigurationError.new("Configuration for #{setting} is not set"))
    end
  end
end
