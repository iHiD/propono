require File.expand_path('../test_helper', __FILE__)

module Propono
  class ProponoTest < Minitest::Test

    def test_publish_calls_publisher_publish
      topic, message = "Foo", "Bar"
      Publisher.expects(:publish).with(topic, message, {})
      Propono.publish(topic, message)
    end

    def test_publish_sets_suffix_publish
      Propono.config.queue_suffix = "-bar"
      topic = "foo"
      Publisher.expects(:publish).with("foo-bar", '', {})
      Propono.publish(topic, "")
    ensure
      Propono.config.queue_suffix = ""
    end

    def test_subscribe_by_queue_calls_subscribe
      topic = 'foobar'
      Subscriber.expects(:subscribe_by_queue).with(topic)
      Propono.subscribe_by_queue(topic)
    end

    def test_subscribe_by_post_calls_subscribe
      topic, endpoint = 'foo', 'bar'
      Subscriber.expects(:subscribe_by_post).with(topic, endpoint)
      Propono.subscribe_by_post(topic, endpoint)
    end

    def test_listen_to_queue_calls_queue_listener
      topic = 'foobar'
      QueueListener.expects(:listen).with(topic)
      Propono.listen_to_queue(topic)
    end

    def test_listen_to_udp_calls_udp_listener
      UdpListener.expects(:listen).with()
      Propono.listen_to_udp()
    end

    def test_listen_to_tcp_calls_tcp_listener
      TcpListener.expects(:listen).with()
      Propono.listen_to_tcp()
    end

    def test_proxy_udp_calls_listen
      UdpListener.expects(:listen).with()
      Propono.proxy_udp()
    end

    def test_proxy_udp_calls_publish_in_the_block
      topic = "foobar"
      message = "message"
      options = {id: "catdog"}
      Propono.stubs(:listen_to_udp).yields(topic, message, options)
      Publisher.expects(:publish).with(topic, message, options)
      Propono.proxy_udp
    end

    def test_proxy_tcp_calls_listen
      TcpListener.expects(:listen).with()
      Propono.proxy_tcp()
    end

    def test_proxy_tcp_calls_publish_in_the_block
      topic = "foobar"
      message = "message"
      options = {id: "catdog"}
      Propono.stubs(:listen_to_tcp).yields(topic, message, options)
      Publisher.expects(:publish).with(topic, message, options)
      Propono.proxy_tcp
    end
  end
end
