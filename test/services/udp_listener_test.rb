require File.expand_path('../../test_helper', __FILE__)

module Propono
  class UdpListenerTest < Minitest::Test

    def test_intialize_sets_locals
      block = Proc.new {}
      listener = UdpListener.new(&block)
      assert_equal block, listener.instance_variable_get("@processor")
    end

    def test_socket_is_setup_correctly
      host = "my-host"
      port = 1234

      Propono.config.udp_host = host
      Propono.config.udp_port = port

      UDPSocket.any_instance.expects(:bind).with(host, port)

      listener = UdpListener.new() {}
      socket = listener.send(:socket)
    end

    def test_initialize_should_fail_without_a_block
      assert_raises(UdpListenerError) do
        UdpListener.new
      end
    end

    def test_message_is_processed
      udp_msg = "Foobar"
      processor = Proc.new {}
      server = UdpListener.new(&processor)
      socket = mock(recvfrom: [udp_msg])
      server.stubs(socket: socket)
      server.expects(:process_udp_data).with(udp_msg)
      thread = server.send(:receive_and_process)
      thread.join
    end

    def test_processor_is_called_correctly
      topic = "my-topic"
      message = "my-message"
      id = "123asd"
      processor = Proc.new {}
      udp_data = {topic: topic, message: message, id: id}.to_json
      processor.expects(:call).with(topic, message, {id: id})

      server = UdpListener.new(&processor)
      server.send(:process_udp_data, udp_data)
    end

    def test_listen_should_loop
      listener = UdpListener.new {}
      listener.expects(:loop)
      listener.listen
    end
  end

  class UdpListenerLegacyTest < Minitest::Test
    def test_processor_is_called_correctly
      topic = "my-topic"
      message = "my-message"
      processor = Proc.new {}
      udp_data = {topic: topic, message: message}.to_json
      processor.expects(:call).with(topic, message)

      server = UdpListener.new(&processor)
      server.send(:process_udp_data, udp_data)
    end
  end
end
