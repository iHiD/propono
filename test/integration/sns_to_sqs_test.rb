require File.expand_path('../integration_test', __FILE__)

module Propono
  class BrokenPublisher < Propono::Publisher

    def initialize(topic_id, raw_text)
      super(topic_id, "")
      @raw_text = raw_text
    end

    def publish
      topic = TopicCreator.find_or_create(topic_id)
      Thread.new do
        begin
          sns.publish(topic.arn, @raw_text)
        rescue => e
          Propono.config.logger.error "Propono [#{id}]: Failed to send via sns : #{e}"
        end
      end
    end
  end
  
  class SnsToSqsTest < IntegrationTest
    def test_the_message_gets_there
      topic = "test-topic"
      text = "This is my message #{DateTime.now} #{rand()}"
      flunks = []
      message_received = false

      Propono.subscribe_by_queue(topic)

      thread = Thread.new do
        begin
          Propono.listen_to_queue(topic) do |message, context|
            flunks << "Wrong message" unless message == text
            flunks << "Wrong id" unless context[:id] =~ Regexp.new("[a-z0-9]{6}")
            message_received = true
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

      Propono.publish(topic, text)
      flunks << "Test Timeout" unless wait_for_thread(thread)
      flunk(flunks.join("\n")) unless flunks.empty?
    ensure
      thread.terminate
    end
    
    
    def test_failed_messge_is_transferred_to_failed_channel
      topic = "test-topic"
      text = "This is my message #{DateTime.now} #{rand()}"
      flunks = []
      message_received = false
    
      Propono.subscribe_by_queue(topic)
    
      thread = Thread.new do
        begin
          Propono.listen_to_queue(topic) do |message, context|
            raise StandardError.new 'BOOM'
          end
        rescue => e
          flunks << e.message
        ensure
          thread.terminate
        end
      end
      
      failure_listener = Thread.new do
        begin
          Propono.listen_to_queue(topic, channel: :failed) do |message, context|
            flunks << "Wrong message" unless message == text
            flunks << "Wrong id" unless context[:id] =~ Regexp.new("[a-z0-9]{6}")
            message_received = true
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
        failure_listener.terminate
      end
    
      sleep(1) # Make sure the listener has started
    
      Propono.publish(topic, text)
      flunks << "Test Timeout" unless wait_for_thread(thread)
      flunk(flunks.join("\n")) unless flunks.empty?
    ensure
      thread.terminate
    end
    
  end
end
