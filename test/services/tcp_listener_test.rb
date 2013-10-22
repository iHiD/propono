require File.expand_path('../../test_helper', __FILE__)

module Propono
  class TcpListenerTest < Minitest::Test

    def test_intialize_sets_locals
      block = Proc.new {}
      listener = TcpListener.new(&block)
      assert_equal block, listener.instance_variable_get("@processor")
    end

    def test_server_is_setup_correctly
      port = 1234
      Propono.config.tcp_port = port

      TCPServer.expects(:open).with(port)

      listener = TcpListener.new() {}
      server = listener.send(:server)
    end

    def test_initialize_should_fail_without_a_block
      assert_raises(TcpListenerError) do
        TcpListener.new
      end
    end

    def test_message_is_processed
      tcp_msg = "Foobar"
      processor = Proc.new {}
      listener = TcpListener.new(&processor)
      client = mock()
      client.expects(:recvfrom => [tcp_msg])
      client.expects(:close)

      server = mock()
      server.expects(accept: client)

      listener.stubs(server: server)
      listener.expects(:process_tcp_data).with(tcp_msg)
      thread = listener.send(:receive_and_process)
      thread.join
    end

    def test_processor_is_called_correctly
      topic = "my-topic"
      message = "my-message"
      processor = Proc.new {}
      tcp_data = {topic: topic, message: message}.to_json
      processor.expects(:call).with(topic, message)

      listener = TcpListener.new(&processor)
      listener.send(:process_tcp_data, tcp_data)
    end

    def test_listen_should_loop
      listener = TcpListener.new {}
      listener.expects(:loop)
      listener.listen
    end
  end
end

