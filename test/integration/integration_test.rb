require File.expand_path('../../test_helper', __FILE__)

module Propono
  class IntegrationTest < Minitest::Test
    def setup
      super
      Fog.unmock!

      config_file = YAML.load_file( File.expand_path('../../config.yml', __FILE__))
      Propono.config.access_key = config_file['access_key']
      Propono.config.secret_key = config_file['secret_key']
      Propono.config.queue_region = config_file['queue_region']
      Propono.config.application_name = config_file['application_name']
      Propono.config.udp_host = "localhost"
      Propono.config.udp_port = 12543
    end

    def wait_for_thread(thread)
      100.times do |x|
        return true unless thread.alive?
        sleep(0.1)
      end
      false
    end
  end
end


