require 'singleton'

module Propono

  class ConfigurationError < ProponoError
  end

  class Configuration
    include Singleton

    SETTINGS = [
      :access_key, :secret_key, :queue_region,
      :application_name,
      :udp_host, :udp_port,
      :logger
    ]
    attr_writer *SETTINGS

    def initialize
      self.logger = $stderr
    end

    SETTINGS.each do |setting|
      define_method setting do
        get_or_raise(setting)
      end
    end

    private

    def get_or_raise(setting)
      instance_variable_get("@#{setting.to_s}") || 
        raise(ConfigurationError.new("Configuration for #{setting} is not set"))
    end
  end
end

