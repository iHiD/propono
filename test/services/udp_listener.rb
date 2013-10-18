require File.expand_path('../../test_helper', __FILE__)

module Propono
  class UdpListenerTest < Minitest::Test

    def test_intialize_sets_locals
      host = "my-host"
      port = 1234
      block = Proc.new {}

      listener = UdpListener.new(host, port, &block)
      assert_equal host, listener.instance_variable_get("@host")
      assert_equal port, listener.instance_variable_get("@port")
      assert_equal block, listener.instance_variable_get("@processor")
    end

    def test_socket_is_setup_correctly
      host = "my-host"
      port = 1234

      UDPSocket.any_instance.expects(:bind).with(host, port)

      listener = UdpListener.new(host, port) {}
      socket = listener.send(:socket)
    end

    def test_initialize_should_fail_without_a_block
      assert_raises(UdpListenerError) do
        UdpListener.new("qwe", 123)
      end
    end

    def test_message_is_processed
      text = "Foobar123"
      processor = Proc.new {}
      server = UdpListener.new("qwewqe", 123, &processor)
      socket = mock(recvfrom: [text])
      server.stubs(socket: socket)
      processor.expects(:call).with(text)
      thread = server.send(:receive_and_process)
      thread.join
    end

    def test_listen_should_loop
      listener = UdpListener.new("qwewqe", 123) {}
      listener.expects(:loop)
      listener.listen
    end
  end
end
