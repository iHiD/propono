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

    def test_listen_to_queue_calls_queue_listener
      QueueListener.expects(:listen).with(@var1, @var2)
      Propono.listen_to_queue(@var1, @var2)
    end

    def test_listen_to_udp_calls_udp_listener
      UdpListener.expects(:listen).with(@var1, @var2)
      Propono.listen_to_udp(@var1, @var2)
    end
  end
end
