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
        topic,
        {}
      )
      client.listen(topic)
    end

    def test_listen_calls_queue_listener_with_options
      topic = 'foobar'
      options = {foo: 'bar'}

      client = Propono::Client.new
      QueueListener.expects(:listen).with(
        client.aws_client,
        client.config,
        topic,
        options
      )
      client.listen(topic, options)
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
      test_application_name = "my-application"
      client = Propono::Client.new do |config|
        config.application_name = test_application_name
      end
      assert_equal test_application_name, client.config.application_name
    end
  end
end
