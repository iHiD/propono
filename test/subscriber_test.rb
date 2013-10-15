require File.expand_path('../test_helper', __FILE__)

module Propono
  class SubscriberTest < Minitest::Test

    def test_subscribe_call_subscribe_by_queue
      Subscriber.any_instance.expects(:subscribe_by_queue)
      Subscriber.subscribe("topic", :queue)
    end

    def test_subscribe_call_subscribe_by_post
      Subscriber.any_instance.expects(:subscribe_by_post)
      Subscriber.subscribe("topic", :post)
    end

  end
end
