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

      Propono.drain_queue(slow_topic)
      Propono.drain_queue(topic)
      Propono.subscribe_by_queue(topic)

      thread = Thread.new do
        begin
          Propono.listen_to_queue(topic) do |message, context|
            flunks << "Wrong message" unless (message == text || message == slow_text)
            message_received = true if message == text
            slow_message_received = true if message == slow_text
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

      Propono.publish(slow_topic, slow_text, async: false)
      Propono.publish(topic, text, async: false)
      flunks << "Test Timeout" unless wait_for_thread(thread)
      flunk(flunks.join("\n")) unless flunks.empty?
    ensure
      # thread.terminate
    end
  end
end
