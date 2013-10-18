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

    def test_publish_should_call_sns_on_correct_topic_and_message
      topic = "topic123"
      message = "message123"
      topic_arn = "arn123"
      topic = Topic.new(topic_arn)

      TopicCreator.stubs(find_or_create: topic)

      sns = mock()
      sns.expects(:publish).with(topic_arn, message)
      publisher = Publisher.new
      publisher.stubs(sns: sns)

      publisher.publish(topic, message)
    end

    def test_publish_should_propogate_exception_on_topic_creation_error
      TopicCreator.stubs(:find_or_create).raises(TopicCreatorError)

      assert_raises(TopicCreatorError) do
        Publisher.publish("topic", "message")
      end
    end

    def test_publish_creates_a_topic
      topic_id = "Malcs_topic_id"
      topic_arn = "Malcs_topic_arn"
      topic = Topic.new(topic_arn)

      TopicCreator.expects(:find_or_create).with(topic_id).returns(topic)

      sns = mock()
      sns.stubs(:publish)
      publisher = Publisher.new
      publisher.stubs(sns: sns)

      publisher.publish(topic_id, "Foobar")
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
