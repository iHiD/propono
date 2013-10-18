module Propono
  class PublisherError < Exception
  end

  class Publisher
    include Sns

    def self.publish(topic, message, options = {})
      new(topic, message, options).publish
    end

    def initialize(topic_id, message, options = {})
      raise PublisherError.new("Topic is nil") if topic_id.nil?
      raise PublisherError.new("Message is nil") if message.nil?
    end

    def publish
      topic = TopicCreator.find_or_create(topic_id)
      sns.publish(topic.arn, message)
    end
  end
end
