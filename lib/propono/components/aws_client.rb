#require 'aws/sns'
#require 'aws/sqs'
require 'aws-sdk-sns'
require 'aws-sdk-sqs'

module Propono
  class AwsClient
    attr_reader :aws_config
    def initialize(aws_config)
      @aws_config = aws_config
    end

    def publish_to_sns(topic, message)
      sns_client.publish(
        topic_arn: topic.arn,
        message: message.to_json
      )
    end

    def send_to_sqs(queue, message)
      sqs_client.send_message(
        queue_url: queue,
        message_body: message
      )
    end

    def create_topic(name)
      Topic.new(sns_client.create_topic(name: name))
    end

    def create_queue(name)
      url = sqs_client.create_queue(queue_name: name).queue_url
      attributes = sqs_client.get_queue_attributes(queue_url: url, attribute_names: ["QueueArn"]).attributes
      Queue.new(url, attributes)
    end

    def subscribe_sqs_to_sns(queue, topic)
      sns_client.subscribe(
        topic_arn: topic.arn,
        protocol: 'sqs',
        endpoint: queue.arn
      )
    end

    def set_sqs_policy(queue, policy)
      sqs_client.set_queue_attributes(
        queue_url: queue.url,
        attributes: { "Policy": policy }
      )
    end

    def read_from_sqs(queue, num_messages, long_poll: true)
      wait_time_seconds = long_poll ? 20 : 0
      sqs_client.receive_message(
        queue_url: queue.url,
        wait_time_seconds: wait_time_seconds,
        max_number_of_messages: num_messages
      ).messages
    end

    def delete_from_sqs(queue, receipt_handle)
      sqs_client.delete_message(
        queue_url: queue.url,
        receipt_handle: receipt_handle
      )
    end

    private

    def sns_client
      @sns_client ||= Aws::SNS::Client.new(aws_config.aws_options)
    end

    def sqs_client
      @sqs_client ||= Aws::SQS::Client.new(aws_config.aws_options)
    end
  end
end
