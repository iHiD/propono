require File.expand_path('../integration_test', __FILE__)

module Propono
  class SnsToSqsTest < IntegrationTest
    def test_the_message_gets_there
      topic = "test-topic"
      text = "This is my message"
      flunks = []

      Propono.subscribe_by_queue(topic)

      thread = Thread.new do
        begin
          Propono.listen_to_queue(topic) do |message, context|
            flunks << "Wrong message" unless message == text
            flunks << "Wrong id" unless context[:id] =~ Regexp.new("[a-z0-9]{6}")
            break
          end
        rescue => e
          flunks << e.message
        ensure
          thread.terminate
        end
      end

      sleep(2) # Make sure the listener has started

      Propono.publish(topic, text)
      flunks << "Test Timeout" unless wait_for_thread(thread)
      flunk(flunks.join("\n")) unless flunks.empty?
    ensure
      thread.terminate
    end
  end
end
