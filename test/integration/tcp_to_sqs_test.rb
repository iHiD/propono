require File.expand_path('../integration_test', __FILE__)

module Propono
  class UdpToSqsTest < IntegrationTest
    def test_the_message_gets_there
      topic = "test-topic"
      message = "This is my message"
      Propono.config.tcp_host = "localhost"
      Propono.config.tcp_port = 20009

      Propono.subscribe_by_queue(topic)

      tcp_thread = Thread.new do
        Propono.listen_to_tcp do |tcp_topic, tcp_message|
          Propono.publish(tcp_topic, tcp_message)
          tcp_thread.terminate
        end
      end

      sqs_thread = Thread.new do
        Propono.listen_to_queue(topic) do |sqs_message|
          assert_equal message, sqs_message
          sqs_thread.terminate
        end
      end

      Propono.publish(topic, message, protocol: :tcp)
      flunk("Test Timeout") unless wait_for_thread(tcp_thread) && wait_for_thread(sqs_thread)

    ensure
      tcp_thread.terminate
      sqs_thread.terminate
    end
  end
end
