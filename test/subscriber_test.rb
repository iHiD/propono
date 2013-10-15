require File.expand_path('../test_helper', __FILE__)

module Propono
  class SubscriberTest < Minitest::Test

    def test_subscribe_by_queue_calls_queue_subscriber
      subscriber = QueueSubscriber.new("topic")
      QueueSubscriber.expects(:new).with("topic").returns(subscriber)
      QueueSubscriber.any_instance.expects(:subscribe)
      Subscriber.subscribe_by_queue("topic")
    end

    def test_subscribe_by_post_calls_post_subscribe
      subscriber = PostSubscriber.new("topic", 'endpoint')
      PostSubscriber.expects(:new).with("topic", 'endpoint').returns(subscriber)
      PostSubscriber.any_instance.expects(:subscribe)
      Subscriber.subscribe_by_post("topic", "endpoint")
    end

  end
end
