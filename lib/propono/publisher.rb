module Propono
  class PublisherError < Exception
  end

  class Publisher
    include Sns

    def self.publish(topic, message)
      new.publish(topic, message)
    end

    def initialize
    end

    def publish(topic_id, message)
      raise PublisherError.new("Topic is nil") if topic_id.nil?
      raise PublisherError.new("Message is nil") if message.nil?

      topic_arn = TopicCreator.find_or_create(topic_id)
      sns.publish(topic_arn, message)
    end
  end
end
