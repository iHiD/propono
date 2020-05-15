require File.expand_path('../../test_helper', __FILE__)

module Propono
  class IntegrationTest < Minitest::Test

    def propono_client
      config_file = YAML.load_file( File.expand_path('../../config.yml', __FILE__))
      @propono_client ||= Propono::Client.new do |config|
        config.aws_options      = config_file['aws_options']
        config.application_name = config_file['application_name']
      end
    end

    # Wait a max of 20secs before failing the test
    def wait_for_thread(thread, secs = 20)
      (secs * 10).times do |x|
        return true unless thread.alive?
        sleep(0.1)
      end
      false
    end
  end
end


