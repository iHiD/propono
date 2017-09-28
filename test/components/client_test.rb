require File.expand_path('../../test_helper', __FILE__)

module Propono
  class ClientTest < Minitest::Test

    def test_publish_calls_publisher_publish
      topic, message = "Foo", "Bar"
      client = Propono::Client.new
      Publisher.expects(:publish).with(
        client.aws_client,
        client.config,
        topic,
        message,
        {}
      )
      client.publish(topic, message)
    end

    def test_publish_sets_suffix_publish
      queue_suffix = "-bar"
      topic = "foo"
      message = "asdasdasda"

      client = Propono::Client.new
      client.config.queue_suffix = queue_suffix
      Publisher.expects(:publish).with(
        client.aws_client,
        client.config,
        "#{topic}#{queue_suffix}",
        message,
        {}
      )
      client.publish(topic, message)
    end

    def test_listen_calls_queue_listener
      topic = 'foobar'

      client = Propono::Client.new
      QueueListener.expects(:listen).with(
        client.aws_client,
        client.config,
        topic
      )
      client.listen(topic)
    end

    def test_drain_queue_calls_queue_listener
      topic = 'foobar'

      client = Propono::Client.new
      QueueListener.expects(:drain).with(
        client.aws_client,
        client.config,
        topic
      )
      client.drain_queue(topic)
    end

    def test_block_configuration_syntax
      test_key = "foobar-123-access"
      client = Propono::Client.new do |config|
        config.access_key = test_key
      end
      assert_equal test_key, client.config.access_key
    end
  end
end
