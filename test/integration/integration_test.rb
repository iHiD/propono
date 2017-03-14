require File.expand_path('../../test_helper', __FILE__)

module Propono
  class IntegrationTest < Minitest::Test
    def setup
      super
      # TODO
      #Fog.unmock!

      config_file = YAML.load_file( File.expand_path('../../config.yml', __FILE__))
      @propono_client = Propono::Client.new do |config|
        config.access_key = config_file['access_key']
        config.secret_key = config_file['secret_key']
        config.queue_region = config_file['queue_region']
        config.application_name = config_file['application_name']
      end
    end

    # Wait a max of 20secs before failing the test
    def wait_for_thread(thread)
      200.times do |x|
        return true unless thread.alive?
        sleep(0.1)
      end
      false
    end
  end
end


