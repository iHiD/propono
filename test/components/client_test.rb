require File.expand_path('../../test_helper', __FILE__)

module Propono
  class ClientTest < Minitest::Test

    def test_publish_calls_publisher_publish
      skip
      topic, message = "Foo", "Bar"
      Publisher.expects(:publish).with(topic, message, {})
      Propono.publish(topic, message)
    end

    def test_publish_sets_suffix_publish
      skip
      Propono.config.queue_suffix = "-bar"
      topic = "foo"
      Publisher.expects(:publish).with("foo-bar", '', {})
      Propono.publish(topic, "")
    end

    def test_listen_to_queue_calls_queue_listener
      skip
      topic = 'foobar'
      QueueListener.expects(:listen).with(topic)
      Propono.listen_to_queue(topic)
    end

    def test_drain_queue_calls_queue_listener
      skip
      topic = 'foobar'
      QueueListener.expects(:drain).with(topic)
      Propono.drain_queue(topic)
    end
  end
end
