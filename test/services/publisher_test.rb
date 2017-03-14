require File.expand_path('../../test_helper', __FILE__)

module Propono
  class PublisherTest < Minitest::Test

    def test_initialization
      publisher = Publisher.new('topic', 'message')
      refute publisher.nil?
    end

    def test_self_publish_calls_new
      topic = "topic123"
      message = "message123"
      Publisher.expects(:new).with(topic, message).returns(mock(publish: nil))
      Publisher.publish(topic, message)
    end

    def test_initializer_generates_an_id
      publisher = Publisher.new('x','y')
      assert publisher.instance_variable_get(:@id)
    end

    def test_initializer_concats_an_id
      id = "q1w2e3"
      hex = "313abd"
      SecureRandom.expects(:hex).with(3).returns(hex)
      publisher = Publisher.new('x','y', id: id)
      assert_equal "#{id}-#{hex}", publisher.id
    end

    def test_self_publish_calls_publish
      Publisher.any_instance.expects(:publish)
      Publisher.publish("topic", "message")
    end

    def test_publish_logs
      publisher = Publisher.new("foo", "bar")
      publisher.instance_variable_set(:@id, 'abc')
      publisher.stubs(:publish_syncronously)
      Propono.config.logger.expects(:info).with {|x| x =~ /^Propono \[abc\]: Publishing bar to foo.*/}
      publisher.send(:publish)
    end

    def test_publish_proxies_to_sns
      publisher = Publisher.new('topic', 'message')
      publisher.expects(:publish_syncronously)
      publisher.publish
    end

    def test_publish_should_call_sns_on_correct_topic_and_message
      topic = "topic123"
      id = "f123"
      message = "message123"
      topic_arn = "arn123"
      topic = Topic.new(topic_arn)

      TopicCreator.stubs(find_or_create: topic)

      sns = mock()
      sns.expects(:publish).with(topic_arn, {id: id, message: message}.to_json)
      publisher = Publisher.new(topic, message)
      publisher.stubs(id: id, sns: sns)
      thread = publisher.send(:publish_syncronously)
    end

    def test_publish_should_accept_a_hash_for_message
      topic = "topic123"
      id = "foobar123"
      message = {something: ['some', 123, true]}
      body = {id: id, message: message}

      topic_arn = "arn123"
      topic = Topic.new(topic_arn)
      TopicCreator.stubs(find_or_create: topic)

      sns = mock()
      sns.expects(:publish).with(topic_arn, body.to_json)
      publisher = Publisher.new(topic, message)
      publisher.stubs(id: id, sns: sns)
      publisher.send(:publish_syncronously)
    end

    def test_publish_async_should_return_future_of_the_sns_response
      skip
      topic = "topic123"
      id = "foobar123"
      message = "message123"
      body = {id: id, message: message}

      topic_arn = "arn123"
      topic = Topic.new(topic_arn)
      TopicCreator.stubs(find_or_create: topic)

      sns = mock()
      sns.expects(:publish).with(topic_arn, body.to_json).returns(:response)
      publisher = Publisher.new(topic, message, async: true)
      publisher.stubs(id: id, sns: sns)
      assert_same :response, publisher.send(:publish_syncronously).value
    end

    def test_publish_should_propogate_exception_on_topic_creation_error
      TopicCreator.stubs(:find_or_create).raises(TopicCreatorError)

      assert_raises(TopicCreatorError) do
        publisher = Publisher.new("topic", "message")
        publisher.send(:publish_syncronously)
      end
    end

    def test_publish_creates_a_topic
      topic_id = "Malcs_topic_id"
      topic_arn = "Malcs_topic_arn"
      topic = Topic.new(topic_arn)

      TopicCreator.expects(:find_or_create).with(topic_id).returns(topic)

      sns = mock()
      sns.stubs(:publish)
      publisher = Publisher.new(topic_id, "Foobar")
      publisher.stubs(sns: sns)

      publisher.send(:publish_syncronously)
    end

    def test_publish_should_raise_exception_if_topic_is_nil
      assert_raises(PublisherError, "Topic is nil") do
        Publisher.publish(nil, "foobar")
      end
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

    def test_publish_can_be_called_syncronously
      publisher = Publisher.new("topic_id", "message", async: true)
      publisher.expects(:publish_syncronously).never
      publisher.expects(:publish_asyncronously).once
      publisher.send(:publish)
    end

    def test_publish_is_normally_called_syncronously
      publisher = Publisher.new("topic_id", "message")
      publisher.expects(:publish_syncronously)
      publisher.send(:publish)
    end
  end
end
