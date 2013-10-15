require File.expand_path('../test_helper', __FILE__)

module Propono
  class PostSubscriberTest < Minitest::Test
    def test_create_topic
      topic = 'foobar'
      TopicCreator.expects(:find_or_create).with(topic)
      PostSubscriber.subscribe(topic, "foobar")
    end

    def test_subscribe_calls_subscribe
      arn = "arn123"
      endpoint = "http://meducation.net/some_queue_name"

      TopicCreator.stubs(find_or_create: arn)

      sns = mock()
      sns.expects(:subscribe).with(arn, endpoint, 'http')
      subscriber = PostSubscriber.new("Some topic", endpoint)
      subscriber.stubs(sns: sns)
      subscriber.subscribe
    end

    def test_it_correctly_uses_http_and_https
      skip
    end
  end
end

