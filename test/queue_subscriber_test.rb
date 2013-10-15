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
      sqs.expects(:create_queue).with(subscriber.send(:queue_name)).returns(mock(body: {'QueueUrl' => Fog::AWS::SQS::Mock::QueueUrl}))
      QueueCreator.any_instance.stubs(sqs: sqs)

      subscriber.subscribe
    end

    def test_subscriber_queue_name
      skip
    end

    def test_subscribe_calls_subscribe
      arn = "arn123"
      queue_url = 

      TopicCreator.stubs(find_or_create: arn)
      QueueCreator.stubs(find_or_create: Queue.new(Fog::AWS::SQS::Mock::QueueUrl))

      sns = mock()
      sns.expects(:subscribe).with(arn, Fog::AWS::SQS::Mock::QueueArn, 'sqs')
      subscriber = QueueSubscriber.new("Some topic")
      subscriber.stubs(sns: sns)
      subscriber.subscribe
    end

    def test_subscribe_saves_queue
      queue = Queue.new(Fog::AWS::SQS::Mock::QueueUrl)

      QueueCreator.expects(:find_or_create).returns(queue)
      subscriber = QueueSubscriber.new("Some Topic")
      subscriber.subscribe
      assert_equal queue, subscriber.queue
    end
  end
end
