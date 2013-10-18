module Propono
  class QueueSubscription

    include Sns
    include Sqs

    attr_reader :topic_arn, :queue

    def self.create(topic_id)
      new(topic_id).tap do |subscription|
        subscription.create
      end
    end

    def initialize(topic_id)
      @topic_id = topic_id
    end

    def create
      @topic = TopicCreator.find_or_create(@topic_id)
      @queue = QueueCreator.find_or_create(queue_name)
      sns.subscribe(@topic.arn, @queue.arn, 'sqs')
      sqs.set_queue_attributes(@queue.url, "Policy", policy)
    end

    def queue_name
      @queue_name ||= "#{config.application_name.gsub(" ", "_")}-#{@topic_id}"
    end

    private

    def config
      Configuration.instance
    end

    def policy
      <<-EOS
      {
        "Version": "2008-10-17",
        "Id": "arn:aws:sqs:eu-west-1:950417255687:manual_queue/SQSDefaultPolicy",
        "Statement": [
          {
            "Sid": "Sid1382106399628",
            "Effect": "Allow",
            "Principal": {
              "AWS": "*"
            },
            "Action": "SQS:SendMessage",
            "Resource": "arn:aws:sqs:eu-west-1:950417255687:manual_queue",
            "Condition": {
              "ArnEquals": {
                "aws:SourceArn": "arn:aws:sns:eu-west-1:950417255687:metrics"
              }
            }
          }
        ]
      }
      EOS
    end
  end
end
