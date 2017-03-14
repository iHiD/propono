require File.expand_path('../../test_helper', __FILE__)

module Propono
  class PublisherTest < Minitest::Test

    def test_initialization
      publisher = Publisher.new(aws_client, propono_config, 'topic', 'message')
      refute publisher.nil?
    end

    def test_self_publish_calls_new
      topic = "topic123"
      message = "message123"
      Publisher.expects(:new).with(aws_client, topic, message).returns(mock(publish: nil))
      Publisher.publish(aws_client, topic, message)
    end

    def test_initializer_generates_an_id
      publisher = Publisher.new(aws_client, propono_config, 'x','y')
      assert publisher.instance_variable_get(:@id)
    end

    def test_initializer_concats_an_id
      id = "q1w2e3"
      hex = "313abd"
      SecureRandom.expects(:hex).with(3).returns(hex)
      publisher = Publisher.new(aws_client, propono_config, 'x','y', id: id)
      assert_equal "#{id}-#{hex}", publisher.id
    end

    def test_self_publish_calls_publish
      Publisher.any_instance.expects(:publish)
      Publisher.publish(aws_client, propono_config, "topic", "message")
    end

    def test_publish_logs
      publisher = Publisher.new(aws_client, propono_config, "foo", "bar")
      publisher.instance_variable_set(:@id, 'abc')
      publisher.stubs(:publish_syncronously)
      propono_config.logger.expects(:info).with {|x| x =~ /^Propono \[abc\]: Publishing bar to foo.*/}
      publisher.publish
    end

    def test_publish_should_call_sns_on_correct_topic_and_message
      topic_name = "topic123"
      id = "f123"
      message = "message123"

      topic = mock
      topic_arn = "arn123"
      topic.stubs(arn: topic_arn)

      aws_client.expects(:create_topic).with(topic_name).returns(topic)
      aws_client.expects(:publish_to_sns).with(
        topic,
        {id: id, message: message}
      )

      publisher = Publisher.new(aws_client, propono_config, topic_name, message)
      publisher.stubs(id: id)
      publisher.publish
    end

    def test_publish_should_accept_a_hash_for_message
      topic_name = "topic123"
      id = "foobar123"
      message = {something: ['some', 123, true]}
      body = {id: id, message: message}

      topic = mock
      topic_arn = "arn123"
      topic.stubs(topic_arn: topic_arn)

      topic = mock
      topic_arn = "arn123"
      topic.stubs(arn: topic_arn)

      aws_client.expects(:create_topic).with(topic_name).returns(topic)
      aws_client.expects(:publish_to_sns).with(topic, body)

      publisher = Publisher.new(aws_client, propono_config, topic_name, message)
      publisher.stubs(id: id)
      publisher.publish
    end

    def test_publish_async_should_return_future_of_the_sns_response
      skip "Rebuild this maybe"
      topic = "topic123"
      id = "foobar123"
      message = "message123"
      body = {id: id, message: message}

      topic_arn = "arn123"
      topic = Topic.new(topic_arn)

      sns = mock()
      sns.expects(:publish).with(topic_arn, body.to_json).returns(:response)
      publisher = Publisher.new(aws_client, propono_config, topic, message, async: true)
      publisher.stubs(id: id, sns: sns)
      assert_same :response, publisher.send(:publish_syncronously).value
    end

    def test_publish_should_propogate_exception_on_topic_creation_error
      aws_client.expects(:create_topic).raises(RuntimeError)
      publisher = Publisher.new(aws_client, propono_config, "topic", "message")

      assert_raises(RuntimeError) do
        publisher.publish
      end
    end

    def test_publish_should_raise_exception_if_topic_is_nil
      assert_raises(PublisherError, "Topic is nil") do
        Publisher.publish(aws_client, propono_config, nil, "foobar")
      end
    end

    def test_publish_should_raise_exception_if_topic_is_nil
      assert_raises(PublisherError, "Topic is nil") do
        Publisher.publish(aws_client, propono_config, nil, "foobar")
      end
    end

    def test_publish_should_raise_exception_if_message_is_nil
      assert_raises(PublisherError, "Message is nil") do
        Publisher.publish(aws_client, propono_config, "foobar", nil)
      end
    end

    def test_publish_can_be_called_syncronously
      publisher = Publisher.new(aws_client, propono_config, "topic_name", "message", async: true)
      publisher.expects(:publish_syncronously).never
      publisher.expects(:publish_asyncronously).once
      publisher.publish
    end

    def test_publish_is_normally_called_syncronously
      publisher = Publisher.new(aws_client, propono_config, "topic_name", "message")
      publisher.expects(:publish_syncronously)
      publisher.publish
    end
  end
end
