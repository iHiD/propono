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
      Propono.config.logger.error $!, $!.backtrace
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
      Propono.config.logger.error "Error parsing message, moving to corrupt queue", $!, $!.backtrace
      move_to_corrupt_queue(raw_sqs_message)
      delete_message(raw_sqs_message)
      nil
    end

    def handle(sqs_message)
      process_message(sqs_message)
    rescue => e
      Propono.config.logger.error("Failed to handle message #{e.message} #{e.backtrace}")
      move_to_failed_queue(sqs_message, e)
    end

    def process_message(sqs_message)
      @message_processor.call(sqs_message.message, sqs_message.context)
    end

    def move_to_corrupt_queue(raw_sqs_message)
      sqs.send_message(corrupt_queue_url, raw_sqs_message["Body"])
    end

    def move_to_failed_queue(sqs_message, exception)
      next_queue = (sqs_message.failure_count < 3) ? queue_url : failed_queue_url
      Propono.config.logger.error "Error proessing message, moving to queue: #{next_queue}"
      sqs.send_message(next_queue, sqs_message.to_json_with_exception(exception))
    end

    def delete_message(raw_sqs_message)
      sqs.delete_message(queue_url, raw_sqs_message['ReceiptHandle'])
    end

    def queue_url
      @queue_url ||= subscription.queue.url
    end

    def failed_queue_url
      @failed_queue_url ||= subscription.failed_queue.url
    end

    def corrupt_queue_url
      @corrupt_queue_url ||= subscription.corrupt_queue.url
    end

    def subscription
      @subscription ||= QueueSubscription.create(@topic_id)
    end

  end
end
