require 'json'

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
      json = Propono::Utils.symbolize_keys JSON.parse(udp_data)

      # Legacy syntax is covered in the else statement
      # This conditional and the else block will be removed in v1.
      if json[:id]
        @processor.call(json[:topic], json[:message], id: json[:id])
      else
        Propono.config.logger.info("Sending and receiving messages without ids is deprecated")
        @processor.call(json[:topic], json[:message])
      end
    end

    def socket
      @socket ||= begin
        socket = UDPSocket.new
        socket.bind(Propono.config.udp_host, Propono.config.udp_port)
        socket
      end
    end
  end
end


