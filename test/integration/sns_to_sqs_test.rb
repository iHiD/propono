require File.expand_path('../../test_helper', __FILE__)

module Propono
  class SnsToSqsTest < Minitest::Test

    def setup
      super
      Fog.unmock!

      config_file = YAML.load_file( File.expand_path('../../config.yml', __FILE__))
      Propono.config.access_key = config_file['access_key']
      Propono.config.secret_key = config_file['secret_key']
      Propono.config.queue_region = config_file['queue_region']
      Propono.config.application_name = config_file['application_name']
    end

    def test_the_message_gets_there
      topic = "test-topic"
      text = "This is my message"

      thread = Thread.new do
        Propono.listen_to_queue(topic) do |message|
          output = JSON.parse(message["Body"])["Message"]
          assert_equal text, output
          break
        end
      end
      Propono.publish(topic, text)

      # Wait for the response. If it hasn't arrived after 10secs, exit.
      passed = false
      100.times do |x|
        unless thread.alive?
          passed = true
          break
        end
        sleep(0.1)
      end
      flunk unless passed
    ensure
      thread.terminate
    end
  end
end
