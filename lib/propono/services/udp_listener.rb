module Propono
  class UdpListenerError < StandardError
  end

  class UdpListener

    def self.listen(&processor)
      new(&processor).listen
    end

    def initialize(&processor)
      raise UdpListenerError.new("Please provide a block to call for each message") unless block_given?
      @processor = processor
    end

    def listen
      loop { receive_and_process }
    end

    private

    def receive_and_process
      text = socket.recvfrom(1024)[0]
      Thread.new { @processor.call(text) }
    end

    def socket
      @socket ||= begin
        socket = UDPSocket.new
        socket.bind(@host, @port)
        socket
      end
    end

    def config
      Configuration.instance
    end

  end
end


