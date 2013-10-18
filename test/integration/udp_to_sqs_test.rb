require File.expand_path('../integration_test', __FILE__)

module Propono
  class UdpToSqsTest < IntegrationTest
    def test_the_message_gets_there
      topic = "test-topic"
      text = "This is my message"

      udp_thread = Thread.new do
        Propono.listen_to_udp do |message|
          Propono.publish(topic, message)
          udp_thread.terminate
        end
      end

      sqs_thread = Thread.new do
        Propono.listen_to_queue(topic) do |message|
          output = JSON.parse(message["Body"])["Message"]
          assert_equal text, output
          sqs_thread.terminate
        end
      end

      Propono.publish(topic, text, protocol: :udp)
      flunk unless wait_for_thread(udp_thread) && wait_for_thread(sqs_thread)
    ensure
      udp_thread.terminate
      sqs_thread.terminate
    end
  end
end
