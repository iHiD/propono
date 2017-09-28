require File.expand_path('../integration_test', __FILE__)

module Propono
  class SlowQueueTest < IntegrationTest
    def test_slow_messages_are_received
      topic = "propono-tests-slow-queue-topic"
      slow_topic = "propono-tests-slow-queue-topic-slow"
      text = "This is my message #{DateTime.now} #{rand()}"
      slow_text = "This is my slow message #{DateTime.now} #{rand()}"
      flunks = []
      message_received = false
      slow_message_received = false

      propono_client.drain_queue(topic)
      propono_client.drain_queue(slow_topic)

      propono_client.subscribe(topic)

      thread = Thread.new do
        begin
          propono_client.listen(topic) do |message, context|
            flunks << "Wrong message" unless (message == text || message == slow_text)
            message_received = true if message == text
            slow_message_received = true if message == slow_text
            thread.terminate if message_received && slow_message_received
          end
        rescue => e
          flunks << e.message
        ensure
          thread.terminate
        end
      end

      Thread.new do
        sleep(1) while !message_received
        sleep(1) while !slow_message_received
        sleep(5) # Make sure all the message deletion clear up in the thread has happened
        thread.terminate
      end

      sleep(1) # Make sure the listener has started

      propono_client.publish(slow_topic, slow_text)
      propono_client.publish(topic, text)

      flunks << "Test Timeout" unless wait_for_thread(thread, 60)
      flunk(flunks.join("\n")) unless flunks.empty?
    ensure
      thread.terminate if thread
    end
  end
end
