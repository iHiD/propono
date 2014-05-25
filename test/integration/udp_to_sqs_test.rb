require File.expand_path('../integration_test', __FILE__)

module Propono
  class UdpToSqsTest < IntegrationTest
    def test_the_message_gets_there
      topic = "propono-tests-udp-to-sqs-topic"
      message = "This is my message #{DateTime.now} #{rand()}"
      flunks = []
      message_received = false

      Propono.config.udp_port = 20002

      Propono.subscribe_by_queue(topic)

      sqs_thread = Thread.new do
        begin
          Propono.listen_to_queue(topic) do |sqs_message|
            assert_equal message, sqs_message
            sqs_thread.terminate
            message_received = true
          end
        rescue => e
          flunks << e.message
        ensure
          sqs_thread.terminate
        end
      end

      Thread.new do
        sleep(1) while !message_received
        sleep(5) # Make sure all the message deletion clear up in the thread has happened
        sqs_thread.terminate
      end

      udp_thread = Thread.new do
        Propono.listen_to_udp do |udp_topic, udp_message|
          Propono.publish(udp_topic, udp_message)
          udp_thread.terminate
        end
      end

      sleep(1) # Make sure the listener has started

      Propono.publish(topic, message, protocol: :udp)
      flunks << "Test Timeout" unless wait_for_thread(udp_thread) && wait_for_thread(sqs_thread)
      flunk(flunks.join("\n")) unless flunks.empty?
    ensure
      udp_thread.terminate
      sqs_thread.terminate
    end
  end
end
