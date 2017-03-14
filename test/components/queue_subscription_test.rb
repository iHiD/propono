require File.expand_path('../../test_helper', __FILE__)

module Propono
  class QueueSubscriptionTest < Minitest::Test
    def setup
      super
      @suffix = "-suf"
      propono_config.queue_suffix = @suffix
    end

    def teardown
      super
      propono_config.queue_suffix = ""
    end

    def test_create_calls_submethods
      subscription = QueueSubscription.new(aws_client, propono_config, "foobar")
      subscription.expects(:create_and_subscribe_main_queue)
      subscription.expects(:create_and_subscribe_slow_queue)
      subscription.expects(:create_misc_queues)
      subscription.create
    end

    def test_create_main_queue
      policy = "Some policy"
      topic_name = "SomeName"

      subscription = QueueSubscription.new(aws_client, propono_config, topic_name)
      subscription.stubs(:create_and_subscribe_slow_queue)
      subscription.stubs(:create_misc_queues)
      subscription.stubs(generate_policy: policy)
      queue_name = subscription.send(:queue_name)

      topic = mock
      queue = mock
      aws_client.expects(:create_topic).with("#{topic_name}#{@suffix}").returns(topic)
      aws_client.expects(:create_queue).with(queue_name).returns(queue)
      aws_client.expects(:subscribe_sqs_to_sns).with(queue, topic)
      aws_client.expects(:set_sqs_policy).with(queue, policy)

      subscription.create
    end

    def test_create_slow_queue
      policy = "Some policy"
      topic_name = "SomeName"

      subscription = QueueSubscription.new(aws_client, propono_config, topic_name)
      subscription.stubs(:create_and_subscribe_main_queue)
      subscription.stubs(:create_misc_queues)
      subscription.stubs(generate_policy: policy)
      queue_name = subscription.send(:queue_name)

      topic = mock
      queue = mock
      aws_client.expects(:create_topic).with("#{topic_name}#{@suffix}-slow").returns(topic)
      aws_client.expects(:create_queue).with("#{queue_name}-slow").returns(queue)
      aws_client.expects(:subscribe_sqs_to_sns).with(queue, topic)
      aws_client.expects(:set_sqs_policy).with(queue, policy)

      subscription.create
    end

    def test_create_misc_queues
      policy = "Some policy"
      topic_name = "SomeName"

      subscription = QueueSubscription.new(aws_client, propono_config, topic_name)
      subscription.stubs(:create_and_subscribe_main_queue)
      subscription.stubs(:create_and_subscribe_slow_queue)
      subscription.stubs(generate_policy: policy)
      queue_name = subscription.send(:queue_name)

      aws_client.expects(:create_queue).with("#{queue_name}-failed")
      aws_client.expects(:create_queue).with("#{queue_name}-corrupt")

      subscription.create
    end

    def test_subscription_queue_name
      propono_config.application_name = "MyApp"

      topic_name = "Foobar"
      subscription = QueueSubscription.new(aws_client, propono_config, topic_name)

      assert_equal "MyApp-Foobar#{@suffix}", subscription.send(:queue_name)
    end

    def test_subscription_queue_name_with_spaces
      propono_config.application_name = "My App"

      topic_name = "Foobar"
      subscription = QueueSubscription.new(aws_client, propono_config, topic_name)

      assert_equal "My_App-Foobar#{@suffix}", subscription.send(:queue_name)
    end

    def test_create_saves_queue
      skip "Need to rebuild this if we acutally need all these things"
      queue = mock
      failed_queue = mock
      corrupt_queue = mock
      slow_queue = mock

      QueueCreator.expects(:find_or_create).with('MyApp-SomeTopic-suf').returns(queue)
      QueueCreator.expects(:find_or_create).with('MyApp-SomeTopic-suf-failed').returns(failed_queue)
      QueueCreator.expects(:find_or_create).with('MyApp-SomeTopic-suf-corrupt').returns(corrupt_queue)
      QueueCreator.expects(:find_or_create).with('MyApp-SomeTopic-suf-slow').returns(slow_queue)
      subscription = QueueSubscription.new(aws_client, propono_config, "SomeTopic")
      subscription.create

      assert_equal queue, subscription.queue
      assert_equal failed_queue, subscription.failed_queue
      assert_equal corrupt_queue, subscription.corrupt_queue
    end

    def test_create_raises_with_nil_topic
      subscription = QueueSubscription.new(aws_client, propono_config, nil)
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

      assert_equal policy, QueueSubscription.new(aws_client, propono_config, nil).send(:generate_policy, queue, topic)
    end
  end
end
