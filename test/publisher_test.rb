require File.expand_path('../test_helper', __FILE__)

module Propono
  class PublisherTest < Minitest::Test

    def test_initialization
      notifier = Publisher.new
      refute notifier.nil?
    end

    def test_self_publish_calls_publish
      topic = "topic123"
      message = "message123"
      Publisher.any_instance.expects(:publish).with(topic, message)
      Publisher.new.publish(topic, message)
    end

    def test_publish_should_call_sns_on_correct_topic
    end

    def test_publish_should_call_sns_with_message
    end

    def test_publish_creates_a_topic
      topic = "Malcs_topic"
      TopicCreator.expects(:find_or_create).with(topic)
      Publisher.new.publish(topic, "Foobar")
    end

    def test_publish_should_raise_exception_if_topic_is_nil
      assert_raises(PublisherError, "Topic is nil") do
        Publisher.publish(nil, "foobar")
      end
    end

    def test_publish_should_raise_exception_if_message_is_nil
      assert_raises(PublisherError, "Message is nil") do
        Publisher.publish("foobar", nil)
      end
    end

  end
end
