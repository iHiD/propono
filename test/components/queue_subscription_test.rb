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
      slow_topic_id = 'foobar-slow'
      slow_topic = Topic.new(slow_topic_id)
      TopicCreator.expects(:find_or_create).with("#{topic_id}#{@suffix}").returns(topic)
      TopicCreator.expects(:find_or_create).with("#{topic_id}#{@suffix}-slow").returns(slow_topic)
      QueueSubscription.create(topic_id)
    end

    def test_sqs_create_is_called
      topic_id = "Foobar"
      subscription = QueueSubscription.new(topic_id)

      TopicCreator.stubs(find_or_create: Topic.new("1123"))

      queue_name = subscription.send(:queue_name)

      sqs = Fog::AWS::SQS::Mock.new
      sqs.expects(:create_queue).with(queue_name).returns(mock(body: {'QueueUrl' => Fog::AWS::SQS::Mock::QueueUrl}))
      sqs.expects(:create_queue).with(queue_name + '-failed').returns(mock(body: {'QueueUrl' => Fog::AWS::SQS::Mock::QueueUrl}))
      sqs.expects(:create_queue).with(queue_name + '-corrupt').returns(mock(body: {'QueueUrl' => Fog::AWS::SQS::Mock::QueueUrl}))
      sqs.expects(:create_queue).with(queue_name + '-slow').returns(mock(body: {'QueueUrl' => Fog::AWS::SQS::Mock::QueueUrl}))
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
      sns.expects(:subscribe).with(arn, Fog::AWS::SQS::Mock::QueueArn, 'sqs').twice
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
      sqs.expects(:set_queue_attributes).with(Fog::AWS::SQS::Mock::QueueUrl, "Policy", policy).twice
      subscription = QueueSubscription.new("Some topic")
      subscription.stubs(sqs: sqs)
      subscription.stubs(generate_policy: policy)
      subscription.create
    end

    def test_create_saves_queue
      queue = Queue.new(Fog::AWS::SQS::Mock::QueueUrl)
      failed_queue = Queue.new(Fog::AWS::SQS::Mock::QueueUrl)
      corrupt_queue = Queue.new(Fog::AWS::SQS::Mock::QueueUrl)
      slow_queue = Queue.new(Fog::AWS::SQS::Mock::QueueUrl)

      QueueCreator.expects(:find_or_create).with('MyApp-SomeTopic-suf').returns(queue)
      QueueCreator.expects(:find_or_create).with('MyApp-SomeTopic-suf-failed').returns(failed_queue)
      QueueCreator.expects(:find_or_create).with('MyApp-SomeTopic-suf-corrupt').returns(corrupt_queue)
      QueueCreator.expects(:find_or_create).with('MyApp-SomeTopic-suf-slow').returns(slow_queue)
      subscription = QueueSubscription.new("SomeTopic")
      subscription.create

      assert_equal queue, subscription.queue
      assert_equal failed_queue, subscription.failed_queue
      assert_equal corrupt_queue, subscription.corrupt_queue
    end

    def test_create_raises_with_nil_topic
      subscription = QueueSubscription.new(nil)
      assert_raises ProponoError do
        subscription.create
      end
    end

    def test_generate_policy
      queue_arn = "queue-arn"
      topic_arn = "topic-arn"
      queue = mock().tap {|m|m.stubs(arn: queue_arn)}
      topic = mock().tap {|m|m.stubs(arn: topic_arn)}

      policy = <<-EOS
{
  "Version": "2008-10-17",
  "Id": "#{queue_arn}/SQSDefaultPolicy",
  "Statement": [
    {
      "Sid": "#{queue_arn}-Sid",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "SQS:*",
      "Resource": "#{queue_arn}",
      "Condition": {
        "StringEquals": {
          "aws:SourceArn": "#{topic_arn}"
        }
      }
    }
  ]
}
EOS

      assert_equal policy, QueueSubscription.new(nil).send(:generate_policy, queue, topic)
    end
  end
end
