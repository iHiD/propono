require File.expand_path('../test_helper', __FILE__)

module Propono
  class SubscriberTest < Minitest::Test

    def test_subscribe_by_queue_calls_queue_subscriber
      QueueSubscriber.any_instance.expects(:subscribe).with("topic")
      Subscriber.subscribe_by_queue("topic")
    end

    def test_subscribe_by_post_calls_post_subscriber
      PostSubscriber.any_instance.expects(:subscribe).with("topic", "endpoint")
      Subscriber.subscribe_by_post("topic", "endpoint")
    end

  end
end
