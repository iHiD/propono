require File.expand_path('../integration_test', __FILE__)

module Propono
  class SnsToSqsTest < IntegrationTest
    def test_the_message_gets_there
      topic = "test-topic"
      text = "This is my message"

      Propono.subscribe_by_queue(topic)

      thread = Thread.new do
        Propono.listen_to_queue(topic) do |message|
          assert_equal text, message
          break
        end
      end

      sleep(2) # Make sure the listener has started

      Propono.publish(topic, text)
      flunk("Test Timeout") unless wait_for_thread(thread)
    ensure
      thread.terminate
    end
  end
end
