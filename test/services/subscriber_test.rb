require File.expand_path('../../test_helper', __FILE__)

module Propono
  class SubscriberTest < Minitest::Test

    def test_subscribe_by_queue_calls_queue_subscriber
      subscriber = QueueSubscription.new("topic")
      QueueSubscription.expects(:new).with("topic", {}).returns(subscriber)
      QueueSubscription.any_instance.expects(:create)
      Subscriber.subscribe_by_queue("topic")
    end

    def test_subscribe_by_post_calls_post_subscribe
      subscriber = PostSubscription.new("topic", 'endpoint')
      PostSubscription.expects(:new).with("topic", 'endpoint').returns(subscriber)
      PostSubscription.any_instance.expects(:create)
      Subscriber.subscribe_by_post("topic", "endpoint")
    end

  end
end
