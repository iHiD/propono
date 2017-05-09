module Propono
  class ProponoConfigurationError < ProponoError
  end

  class Configuration
    SETTINGS = %i[
      use_iam_profile access_key secret_key queue_region queue_suffix
      application_name udp_host udp_port tcp_host tcp_port logger
      max_retries num_messages_per_poll
    ].freeze
    attr_writer(*SETTINGS)

    def initialize
      self.logger = Propono::Logger.new
      self.queue_suffix = ''
      self.access_key = ''
      self.secret_key = ''
      self.use_iam_profile = false
      self.max_retries = 0
      self.num_messages_per_poll = 10
    end

    SETTINGS.each do |setting|
      define_method setting do
        get_or_raise(setting)
      end
    end

    attr_reader :use_iam_profile, :queue_suffix

    private

    def get_or_raise(setting)
      val = instance_variable_get("@#{setting}")
      raise ProponoConfigurationError, "Configuration for #{setting} is not set" if val.nil?
      val
    end
  end
end
