require File.expand_path('../integration_test', __FILE__)

module Propono
  class SnsToSqsTest < IntegrationTest
    def test_the_message_gets_there
      topic = "propono-tests-sns-to-sqs-topic"
      text = "This is my message #{DateTime.now} #{rand()}"
      flunks = []
      message_received = false

      propono_client.drain_queue(topic)
      propono_client.subscribe(topic)

      thread = Thread.new do
        begin
          propono_client.listen(topic) do |message, context|
            flunks << "Wrong message" unless message == text
            flunks << "Wrong id" unless context[:id] =~ Regexp.new("[a-z0-9]{6}")
            message_received = true
            thread.terminate
          end
        rescue => e
          flunks << e.message
        ensure
          thread.terminate
        end
      end

      Thread.new do
        sleep(1) while !message_received
        sleep(5) # Make sure all the message deletion clear up in the thread has happened
        thread.terminate
      end

      sleep(1) # Make sure the listener has started

      propono_client.publish(topic, text)
      flunks << "Test Timeout" unless wait_for_thread(thread)
      flunk(flunks.join("\n")) unless flunks.empty?
    ensure
      thread.terminate if thread
    end

=begin
    def test_failed_messge_is_transferred_to_failed_channel
      topic = "propono-tests-sns-to-sqs-topic-failed"
      text = "This is my message #{DateTime.now} #{rand()}"
      flunks = []
      message_received = false

      propono_client.drain_queue(topic)
      propono_client.subscribe(topic)

      thread = Thread.new do
        begin
          propono_client.listen(topic) do |message, context|
            raise StandardError.new 'BOOM'
          end
        rescue => e
          flunks << e.message
        ensure
          thread.terminate
        end
      end

      failure_thread = Thread.new do
        begin
          propono_client.listen(topic, channel: :failed) do |message, context|
            flunks << "Wrong message" unless message == text
            flunks << "Wrong id" unless context[:id] =~ Regexp.new("[a-z0-9]{6}")
            message_received = true
            failure_thread.terminate
          end
        rescue => e
          flunks << e.message
        ensure
          thread.terminate
        end
      end

      Thread.new do
        sleep(1) while !message_received
        p "Message received"
        sleep(5) # Make sure all the message deletion clear up in the thread has happened
        thread.terminate
        failure_thread.terminate
      end

      sleep(1) # Make sure the listener has started

      propono_client.publish(topic, text)
      flunks << "Test Timeout" unless wait_for_thread(thread)
      flunk(flunks.join("\n")) unless flunks.empty?
    ensure
      thread.terminate if thread
    end
=end
  end
end
