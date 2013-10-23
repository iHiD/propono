module Propono

  class ProponoConfigurationError < ProponoError
  end

  class Configuration

    SETTINGS = [
      :access_key, :secret_key, :queue_region,
      :application_name,
      :udp_host, :udp_port,
      :tcp_host, :tcp_port,
      :logger
    ]
    attr_writer *SETTINGS

    def initialize
      self.logger = Propono::Logger.new
    end

    SETTINGS.each do |setting|
      define_method setting do
        get_or_raise(setting)
      end
    end

    private

    def get_or_raise(setting)
      instance_variable_get("@#{setting.to_s}") || 
        raise(ProponoConfigurationError.new("Configuration for #{setting} is not set"))
    end
  end
end

