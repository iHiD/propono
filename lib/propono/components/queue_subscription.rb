module Propono
  class QueueSubscription

    include Sns
    include Sqs

    attr_reader :topic_arn, :queue_name, :queue

    def self.create(topic_id, options = {})
      new(topic_id, options).tap do |subscription|
        subscription.create
      end
    end

    def initialize(topic_id, options = {})
      @topic_id = topic_id
      @suffixed_topic_id = "#{topic_id}#{Propono.config.queue_suffix}"
      @queue_name = "#{Propono.config.application_name.gsub(" ", "_")}-#{@suffixed_topic_id}#{options[:queue_name_suffix]}"
    end

    def create
      raise ProponoError.new("topic_id is nil") unless @topic_id
      @topic = TopicCreator.find_or_create(@suffixed_topic_id)
      @queue = QueueCreator.find_or_create(queue_name)
      sns.subscribe(@topic.arn, @queue.arn, 'sqs')
      sqs.set_queue_attributes(@queue.url, "Policy", generate_policy)
    end

    private

    def generate_policy
      <<-EOS
{
  "Version": "2008-10-17",
  "Id": "#{@queue.arn}/SQSDefaultPolicy",
  "Statement": [
    {
      "Sid": "#{@queue.arn}-Sid",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "SQS:*",
      "Resource": "#{@queue.arn}"
    }
  ]
}
      EOS
    end
  end
end
