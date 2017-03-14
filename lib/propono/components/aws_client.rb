module Propono
  class AwsClient
    def initialize
    end

    def publish_to_sns(arn, message)
      sns_client.publish(
        topic_arn: arn,
        message: message.to_json
      )
    end

    def create_topic(name)
      Topic.new(sns_client.create_topic(name: name))
    end

    def create_queue(name)
      Topic.new(sns_client.create_topic(name: name))
    end

    def subscribe_sqs_to_sns(queue, topic)
      # aws_client.subscribe(topic.topic_arn, @queue.arn, 'sqs')
    end

    def set_sqs_queue_policy(queue, policy)
      #set_queue_attributes(@queue.url, "Policy", generate_policy(@queue, topic))
    end

    private

    def sns_client
      @sns_client ||= Aws::SNS::Client.new(Propono.aws_options)
    end

    def sqs_client
      @sqs_client ||= Aws::SQS::Client.new(Propono.aws_options)
    end

  end
end
