require File.expand_path('../test_helper', __FILE__)

module Propono
  class ProponoTest < Minitest::Test

    def setup
      super
      @var1 = "Foobar"
      @var2 = 123
    end

    def test_publish_calls_publisher_public
      Publisher.expects(:publish).with(@var1, @var2)
      Propono.publish(@var1, @var2)
    end

    def test_subscribe_by_queue_calls_subscribe
      Subscriber.expects(:subscribe_by_queue).with(@var1, @var2)
      Propono.subscribe_by_queue(@var1, @var2)
    end

    def test_subscribe_by_post_calls_subscribe
      Subscriber.expects(:subscribe_by_post).with(@var1, @var2)
      Propono.subscribe_by_post(@var1, @var2)
    end

    def test_listen_to_queue_calls_queue_listener
      QueueListener.expects(:listen).with(@var1, @var2)
      Propono.listen_to_queue(@var1, @var2)
    end

    def test_listen_to_udp_calls_udp_listener
      UdpListener.expects(:listen).with(@var1, @var2)
      Propono.listen_to_udp(@var1, @var2)
    end

    def test_proxy_udp_calls_listen
      UdpListener.expects(:listen).with()
      Propono.proxy_udp("foobar")
    end

    def test_proxy_udp_calls_publish_in_the_block
      topic = "foobar"
      message = "message"
      Propono.stubs(:listen_to_udp).yields(message)
      Publisher.expects(:publish).with(topic, message)
      Propono.proxy_udp(topic)
    end
  end
end
