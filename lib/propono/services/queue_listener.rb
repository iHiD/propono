module Propono
  class QueueListener

    include Sqs

    def self.listen(queue_url, &block)
      new(queue_url, &block).listen
    end

    def initialize(queue_url, &block)
      @queue_url = queue_url
      @block = block
    end

    def listen
      loop {
        sleep 10 unless read_messages
      }
    end

    private

    def read_messages
      begin
        response = sqs.receive_message( @queue_url, options = { 'MaxNumberOfMessages' => 10 } )
        messages = response.body['Message']
        if messages.empty?
          false
        else
          process_messages(messages)
        end
      rescue
        config.logger.puts "Unexpected error reading from queue #{@queue_url}"
      end
    end

    def process_messages(messages)
      messages.each do |message|
        @block.call(message)
        sqs.delete_message(message['ReceiptHandle'])
      end
      true
    end
  end
end
