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
        messages.each { |msg| process_raw_message(msg) }
      end
    rescue Excon::Errors::Forbidden
      Propono.config.logger.error "Forbidden error caught and re-raised. #{queue_url}"
      Propono.config.logger.error $!
      raise $!
    rescue
      Propono.config.logger.error "Unexpected error reading from queue #{queue_url}"
      Propono.config.logger.error $!
    end

    # The calls to delete_message are deliberately duplicated so
    # as to ensure the message is only deleted if the preceeding line
    # has completed succesfully. We do *not* want to ensure that the
    # message is deleted regardless of what happens in this method.
    def process_raw_message(raw_sqs_message)
      sqs_message = parse(raw_sqs_message)
      unless sqs_message.nil?
        Propono.config.logger.info "Propono [#{sqs_message.context[:id]}]: Received from sqs."
        handle(sqs_message)
        delete_message(raw_sqs_message)
      end
    end
    
    def parse(raw_sqs_message)
      SqsMessage.new(raw_sqs_message)
    rescue
      move_to_corrupt_queue(raw_sqs_message)
      delete_message(raw_sqs_message)
    end

    def handle(sqs_message)
      process_message(sqs_message)
    rescue
      move_to_failed_queue(sqs_message)
    end
    
    def process_message(sqs_message)
      @message_processor.call(sqs_message.message, sqs_message.context)
    end

    def move_to_corrupt_queue(raw_sqs_message)
      QueueSubscription.create(@topic_id, queue_name_suffix: "-corrupt")
      Propono.publish("#{@topic_id}-corrupt", raw_sqs_message)
    end

    def move_to_failed_queue(sqs_message)
      QueueSubscription.create(@topic_id, queue_name_suffix: "-failed")
      Propono.publish("#{@topic_id}-failed", sqs_message.message, id: sqs_message.context[:id])
    end

    def delete_message(raw_sqs_message)
      sqs.delete_message(queue_url, raw_sqs_message['ReceiptHandle'])
    end

    def queue_url
      @queue_url ||= subscription.queue.url
    end

    def subscription
      @subscription ||= QueueSubscription.create(@topic_id)
    end
    
  end
end
