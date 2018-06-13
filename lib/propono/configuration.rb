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

    add_setting :access_key
    add_setting :secret_key
    add_setting :queue_region
    add_setting :application_name
    add_setting :logger
    add_setting :max_retries
    add_setting :num_messages_per_poll

    add_setting :use_iam_profile, required: false
    add_setting :iam_profile_credentials_retries, required: false
    add_setting :iam_profile_credentials_timeout, required: false

    add_setting :queue_suffix,    required: false

    def initialize
      @settings = {
        logger:                Propono::Logger.new,
        queue_suffix:          "",
        use_iam_profile:       false,
        max_retries:           0,
        num_messages_per_poll: 10
      }
    end

    private

    def get_or_raise(setting)
      @settings[setting] || raise(ProponoConfigurationError.new("Configuration for #{setting} is not set"))
    end
  end
end
