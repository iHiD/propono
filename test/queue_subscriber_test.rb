require File.expand_path('../test_helper', __FILE__)

module Propono
  class QueueSubscriberTest < Minitest::Test
    def test_create_topic
      topic = 'foobar'
      TopicCreator.expects(:find_or_create).with(topic)
      QueueSubscriber.subscribe(topic)
    end

    def test_sqs_create_is_called
      topic = "Foobar"
      subscriber = QueueSubscriber.new(topic)

      TopicCreator.stubs(find_or_create: "1123")

      sqs = mock()
      sqs.expects(:create_queue).with(subscriber.send(:queue_name)).returns(mock(body: {'QueueUrl' => "foobar"}))
      QueueCreator.any_instance.stubs(sqs: sqs)

      subscriber.subscribe
    end

    def test_subscriber_queue_name
      skip
    end

    def test_subscribe_calls_subscribe
      arn = "arn123"
      queue_url = "http://meducation.net/some_queue_name"

      TopicCreator.stubs(find_or_create: arn)
      QueueCreator.stubs(find_or_create: queue_url)

      sns = mock()
      sns.expects(:subscribe).with(arn, queue_url, 'sqs')
      subscriber = QueueSubscriber.new("Some topic")
      subscriber.stubs(sns: sns)
      subscriber.subscribe
    end

    def test_subscribe_returns_queue_name
      queue_name = 'foobar'
      QueueCreator.expects(:find_or_create).returns(queue_name)
      return_value = QueueSubscriber.subscribe("Some Topic")
      assert_equal queue_name, return_value
    end
  end
end
