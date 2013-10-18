require File.expand_path('../integration_test', __FILE__)

module Propono
  class SnsToSqsTest < IntegrationTest
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
      flunk unless wait_for_thread(thread)
    ensure
      thread.terminate
    end
  end
end
