module Propono

  class QueueListener
    def self.listen(*args, &message_processor)
      new(*args, &message_processor).listen
    end

    def self.drain(*args, &message_processor)
      new(*args, &message_processor).drain
    end

    attr_reader :aws_client, :propono_config, :topic_name, :visibility_timeout, :message_processor, :idle_timeout
    def initialize(aws_client, propono_config, topic_name, options = {}, &message_processor)
      @aws_client = aws_client
      @propono_config = propono_config
      @topic_name = topic_name
      @message_processor = message_processor
      @visibility_timeout = options[:visibility_timeout] || nil
      @idle_timeout = options[:idle_timeout] || nil
    end

    def listen
      raise ProponoError.new("topic_name is nil") unless topic_name

      reset_idle_timeout!

      loop do
        break if idle_timeout_reached?
        read_messages
      end
    end

    def drain
      raise ProponoError.new("topic_name is nil") unless topic_name
      true while read_messages_from_queue(main_queue, 10, long_poll: false)
      true while read_messages_from_queue(slow_queue, 10, long_poll: false)
    end

    private

    def read_messages
      read_messages_from_queue(main_queue, propono_config.num_messages_per_poll) ||
      read_messages_from_queue(slow_queue, 1)
    end

    def read_messages_from_queue(queue, num_messages, long_poll: true)
      messages = aws_client.read_from_sqs(queue, num_messages, long_poll: long_poll, visibility_timeout: visibility_timeout)
      if messages.empty?
        false
      else
        messages.each { |msg| process_raw_message(msg, queue) }
        reset_idle_timeout!
        true
      end
    rescue => e #Aws::Errors => e
      propono_config.logger.error "Unexpected error reading from queue #{queue.url}"
      propono_config.logger.error e.class.name
      propono_config.logger.error e.message
      propono_config.logger.error e.backtrace
      false
    end

    # The calls to delete_message are deliberately duplicated so
    # as to ensure the message is only deleted if the preceeding line
    # has completed succesfully. We do *not* want to ensure that the
    # message is deleted regardless of what happens in this method.
    def process_raw_message(raw_sqs_message, queue)
      sqs_message = parse(raw_sqs_message, queue)
      return unless sqs_message

      propono_config.logger.info "Propono [#{sqs_message.context[:id]}]: Received from sqs."
      handle(sqs_message)
      aws_client.delete_from_sqs(queue, sqs_message.receipt_handle)
    end

    def parse(raw_sqs_message, queue)
      SqsMessage.new(raw_sqs_message)
    rescue
      propono_config.logger.error "Error parsing message, moving to corrupt queue", $!, $!.backtrace
      move_to_corrupt_queue(raw_sqs_message)
      aws_client.delete_from_sqs(queue, raw_sqs_message.receipt_handle)
      nil
    end

    def handle(sqs_message)
      process_message(sqs_message)
    rescue => e
      propono_config.logger.error("Failed to handle message #{e.message} #{e.backtrace}")
      requeue_message_on_failure(sqs_message, e)
    end

    def process_message(sqs_message)
      return false unless message_processor
      message_processor.call(sqs_message.message, sqs_message.context)
    end

    def move_to_corrupt_queue(raw_sqs_message)
      aws_client.send_to_sqs(corrupt_queue, raw_sqs_message.body)
    end

    def requeue_message_on_failure(sqs_message, exception)
      next_queue = (sqs_message.failure_count < propono_config.max_retries) ? main_queue : failed_queue
      propono_config.logger.error "Error processing message, moving to queue: #{next_queue}"
      aws_client.send_to_sqs(next_queue, sqs_message.to_json_with_exception(exception))
    end

    def delete_message(raw_sqs_message, queue)
      aws_client.delete_from_sqs(queue, raw_sqs_message.receipt_handle)
    end

    def main_queue
      @main_queue ||= subscription.queue
    end

    def failed_queue
      @failed_queue ||= subscription.failed_queue
    end

    def corrupt_queue
      @corrupt_queue ||= subscription.corrupt_queue
    end

    def slow_queue
      @slow_queue ||= subscription.slow_queue
    end

    def subscription
      QueueSubscription.create(aws_client, propono_config, topic_name)
    end

    def idle_timeout_reached?
      if idle_timeout.nil?
        return false
      end

      time_idle = Time.now.to_i - last_message_read_at
      time_idle >= idle_timeout
    end

    def reset_idle_timeout!
      @last_message_read_at = Time.now.to_i
    end

    def last_message_read_at
      @last_message_read_at
    end
  end
end
