require File.expand_path('../test_helper', __FILE__)

module Propono
  class UdpListenerTest < Minitest::Test

    def test_initialize_should_fail_without_a_block
      assert_raises(UdpListenerError) do
        UdpListener.new
      end
    end

    def test_message_is_processed
      text = "Foobar123"
      processor = Proc.new {}
      server = UdpListener.new &processor
      socket = mock(recvfrom: [text])
      server.stubs(socket: socket)
      processor.expects(:call).with(text)
      thread = server.send(:receive_and_process)
      thread.join
    end

    def test_listen_should_loop
      listener = UdpListener.new {}
      listener.expects(:loop)
      listener.listen
    end
  end
end
