require File.expand_path('../integration_test', __FILE__)

module Propono
  class UdpProxyTest < IntegrationTest
    def test_the_message_gets_there
      topic = "test-topic"
      text = "This is my message #{DateTime.now} #{rand()}"
      flunks = []
      message_received = false

      Propono.config.udp_port = 20001

      Propono.subscribe_by_queue(topic)

      sqs_thread = Thread.new do
        begin
          Propono.listen_to_queue(topic) do |message, context|
            flunks << "Wrong message" unless text == message
            flunks << "Wrong id" unless context[:id] =~ Regexp.new("[a-z0-9]{6}-[a-z0-9]{6}")
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
        Propono.proxy_udp
      end

      sleep(1) # Make sure the proxy has started

      Propono::Publisher.publish(topic, text, protocol: :udp)
      flunks << "Test timeout" unless wait_for_thread(sqs_thread)
      flunk(flunks.join("\n")) unless flunks.empty?
    ensure
      udp_thread.terminate
      sqs_thread.terminate
    end
  end
end
