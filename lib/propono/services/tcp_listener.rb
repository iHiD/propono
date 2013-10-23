require 'json'

module Propono
  class TcpListenerError < ProponoError
  end

  class TcpListener

    def self.listen(&processor)
      new(&processor).listen
    end

    def initialize(&processor)
      raise TcpListenerError.new("Please provide a block to call for each message") unless block_given?
      @processor = processor
    end

    def listen
      loop { receive_and_process }
    end

    private

    def receive_and_process
      client = server.accept
      tcp_data = client.recvfrom(1024)[0]
      client.close
      Thread.new { process_tcp_data(tcp_data) }
    end

    def process_tcp_data(tcp_data)
      json = JSON.parse(tcp_data)
      @processor.call(json['topic'], json['message'])
    end

    def server
      @server ||= TCPServer.open(Propono.config.tcp_port)
    end
  end
end
