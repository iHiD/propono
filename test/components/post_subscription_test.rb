require File.expand_path('../../test_helper', __FILE__)

module Propono
  class PostSubscriptionTest < Minitest::Test
    def test_create_topic
      topic = 'foobar'
      TopicCreator.expects(:find_or_create).with(topic)
      PostSubscription.create(topic, "foobar")
    end

    def test_create_calls_create
      arn = "arn123"
      endpoint = "http://meducation.net/some_queue_name"

      TopicCreator.stubs(find_or_create: arn)

      sns = mock()
      sns.expects(:subscribe).with(arn, endpoint, 'http')
      subscription = PostSubscription.new("Some topic", endpoint)
      subscription.stubs(sns: sns)
      subscription.create
    end

    def test_it_correctly_uses_http_and_https
      skip
    end
  end
end

