require File.expand_path('../integration_test', __FILE__)

module Propono
  class UdpToSqsTest < IntegrationTest
    def test_the_message_gets_there
      topic = "test-topic"
      message = "This is my message"
      flunks = []

      Propono.config.tcp_host = "localhost"
      Propono.config.tcp_port = 20009

      Propono.subscribe_by_queue(topic)

      sqs_thread = Thread.new do
        begin
          Propono.listen_to_queue(topic) do |sqs_message|
            flunks << "Wrong message" unless message == sqs_message
            sqs_thread.terminate
          end
        rescue => e
          flunks << e.message
        ensure
          sqs_thread.terminate
        end
      end

      tcp_thread = Thread.new do
        Propono.listen_to_tcp do |tcp_topic, tcp_message|
          Propono.publish(tcp_topic, tcp_message)
          tcp_thread.terminate
        end
      end
      sleep(2) # Make sure the listener has started

      Propono.publish(topic, message, protocol: :tcp)
      flunks << "Test Timeout" unless wait_for_thread(tcp_thread) && wait_for_thread(sqs_thread)
      flunk(flunks.join("\n")) unless flunks.empty?
    ensure
      tcp_thread.terminate
      sqs_thread.terminate
    end
  end
end
