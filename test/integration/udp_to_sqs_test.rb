require File.expand_path('../integration_test', __FILE__)

module Propono
  class UdpToSqsTest < IntegrationTest
    def test_the_message_gets_there
      topic = "test-topic"
      message = "This is my message"
      Propono.config.udp_port = 20002

      Propono.subscribe_by_queue(topic)

      sqs_thread = Thread.new do
        Propono.listen_to_queue(topic) do |sqs_message|
          assert_equal message, sqs_message
          sqs_thread.terminate
        end
      end

      udp_thread = Thread.new do
        Propono.listen_to_udp do |udp_topic, udp_message|
          Propono.publish(udp_topic, udp_message)
          udp_thread.terminate
        end
      end

      sleep(2) # Make sure the listener has started

      Propono.publish(topic, message, protocol: :udp)
      flunk("Test Timeout") unless wait_for_thread(udp_thread) && wait_for_thread(sqs_thread)
    ensure
      udp_thread.terminate
      sqs_thread.terminate
    end
  end
end
