module Propono
  class UdpListenerError < ProponoError
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
      udp_data = socket.recvfrom(1024)[0]
      Thread.new { process_udp_data(udp_data) }
    end

    def process_udp_data(udp_data)
      json = JSON.parse(udp_data)
      @processor.call(json['topic'], json['message'])
    end

    def socket
      @socket ||= begin
        socket = UDPSocket.new
        socket.bind(config.udp_host, config.udp_port)
        socket
      end
    end

    def config
      Configuration.instance
    end

  end
end


