require File.expand_path('../../test_helper', __FILE__)

module Propono
  class QueueSubscriptionTest < Minitest::Test
    def setup
      super
      @suffix = "-suf"
      Propono.config.queue_suffix = @suffix
    end

    def teardown
      super
      Propono.config.queue_suffix = ""
    end

    def test_create_topic
      topic_id = 'foobar'
      topic = Topic.new(topic_id)
      TopicCreator.expects(:find_or_create).with("#{topic_id}#{@suffix}").returns(topic)
      QueueSubscription.create(topic_id)
    end

    def test_sqs_create_is_called
      topic_id = "Foobar"
      subscription = QueueSubscription.new(topic_id)

      TopicCreator.stubs(find_or_create: Topic.new("1123"))

      sqs = mock()
      sqs.expects(:create_queue).with(subscription.send(:queue_name)).returns(mock(body: {'QueueUrl' => Fog::AWS::SQS::Mock::QueueUrl}))
      QueueCreator.any_instance.stubs(sqs: sqs)

      subscription.create
    end

    def test_subscription_queue_name
      Propono.config.application_name = "MyApp"

      topic_id = "Foobar"
      subscription = QueueSubscription.new(topic_id)

      assert_equal "MyApp-Foobar#{@suffix}", subscription.send(:queue_name)
    end

    def test_subscription_queue_name_with_spaces
      Propono.config.application_name = "My App"

      topic_id = "Foobar"
      subscription = QueueSubscription.new(topic_id)

      assert_equal "My_App-Foobar#{@suffix}", subscription.send(:queue_name)
    end

    def test_create_calls_subscribe
      arn = "arn123"

      TopicCreator.stubs(find_or_create: Topic.new(arn))
      QueueCreator.stubs(find_or_create: Queue.new(Fog::AWS::SQS::Mock::QueueUrl))

      sns = mock()
      sns.expects(:subscribe).with(arn, Fog::AWS::SQS::Mock::QueueArn, 'sqs')
      subscription = QueueSubscription.new("Some topic")
      subscription.stubs(sns: sns)
      subscription.create
    end

    def test_create_calls_set_queue_attributes
      arn = "arn123"
      policy = "{foobar: 123}"

      TopicCreator.stubs(find_or_create: Topic.new(arn))
      QueueCreator.stubs(find_or_create: Queue.new(Fog::AWS::SQS::Mock::QueueUrl))

      sqs = mock()
      sqs.expects(:set_queue_attributes).with(Fog::AWS::SQS::Mock::QueueUrl, "Policy", policy)
      subscription = QueueSubscription.new("Some topic")
      subscription.stubs(sqs: sqs)
      subscription.stubs(generate_policy: policy)
      subscription.create
    end

    def test_create_saves_queue
      queue = Queue.new(Fog::AWS::SQS::Mock::QueueUrl)

      QueueCreator.expects(:find_or_create).returns(queue)
      subscription = QueueSubscription.new("Some Topic")
      subscription.create
      assert_equal queue, subscription.queue
    end

    def test_create_raises_with_nil_topic
      subscription = QueueSubscription.new(nil)
      assert_raises ProponoError do
        subscription.create
      end
    end

    def test_generate_policy
      skip "TODO - Implement this test."
    end
  end
end
