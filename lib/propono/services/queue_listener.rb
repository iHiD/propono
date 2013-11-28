module Propono
  class QueueListener

    include Sqs

    def self.listen(topic_id, &message_processor)
      new(topic_id, &message_processor).listen
    end

    def initialize(topic_id, &message_processor)
      @topic_id = topic_id
      @message_processor = message_processor
    end

    def listen
      raise ProponoError.new("topic_id is nil") unless @topic_id
      loop do
        unless read_messages
          sleep 10
        end
      end
    end

    private

    def read_messages
      response = sqs.receive_message( queue_url, {'MaxNumberOfMessages' => 10} )
      messages = response.body['Message']
      if messages.empty?
        false
      else
        messages.each { |msg| process_sqs_message(msg) }
      end
    rescue
      Propono.config.logger.error "Unexpected error reading from queue #{queue_url}"
      Propono.config.logger.error $!
    end

    def process_sqs_message(sqs_message)
      body = JSON.parse(sqs_message["Body"])["Message"]

      # Legacy syntax is covered in the rescue statement
      # This begin/rescue dance and the rescue block will be removed in v1.
      begin
        body = JSON.parse(body)
        context = body.symbolize_keys
        message = context.delete(:message)
        Propono.config.logger.info "Propono [#{context[:id]}]: Received from sqs."
        @message_processor.call(message, context)
      rescue JSON::ParserError, TypeError
        Propono.config.logger.info("Sending and recieving messages without ids is deprecated")
        @message_processor.call(body)
      end
      sqs.delete_message(queue_url, sqs_message['ReceiptHandle'])
    end

    def queue_url
      @queue_url ||= subscription.queue.url
    end

    def subscription
      @subscription ||= QueueSubscription.create(@topic_id)
    end
  end
end
