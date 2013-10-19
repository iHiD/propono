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
      loop do
        unless read_messages
          sleep 10
        end
      end
    end

    private

    def read_messages
      #response = sqs.receive_message( queue_url, options = { 'MaxNumberOfMessages' => 10 } )
      response = sqs.receive_message( queue_url, {'MaxNumberOfMessages' => 10} )
      messages = response.body['Message']
      if messages.empty?
        false
      else
        messages.each { |msg| process_sqs_message(msg) }
      end
    rescue
      config.logger.puts "Unexpected error reading from queue #{queue_url}"
      config.logger.puts $!
    end

    def process_sqs_message(sqs_message)
      message = JSON.parse(sqs_message["Body"])["Message"]
      @message_processor.call(message)
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
