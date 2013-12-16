module Propono

  class ProponoConfigurationError < ProponoError
  end

  class Configuration

    SETTINGS = [
      :use_iam_profile, :access_key, :secret_key, :queue_region, :queue_suffix,
      :application_name,
      :udp_host, :udp_port,
      :tcp_host, :tcp_port,
      :logger
    ]
    attr_writer *SETTINGS

    def initialize
      self.logger = Propono::Logger.new
      self.queue_suffix = ""
      self.use_iam_profile = false
    end

    SETTINGS.each do |setting|
      define_method setting do
        get_or_raise(setting)
      end
    end

    attr_reader :use_iam_profile, :queue_suffix

    private

    def get_or_raise(setting)
      val = instance_variable_get("@#{setting.to_s}")
      val.nil?? raise(ProponoConfigurationError.new("Configuration for #{setting} is not set")) : val
    end
  end
end

