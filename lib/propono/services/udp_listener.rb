module Propono
  class UdpListenerError < StandardError
  end

  class UdpListener

    def self.listen(host, port, &processor)
      new(host, port, &processor).listen
    end

    def initialize(host, port, &processor)
      raise UdpListenerError.new("Please provide a block to call for each message") unless block_given?
      @host = host
      @port = port
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


