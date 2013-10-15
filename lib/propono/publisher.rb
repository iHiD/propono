module Propono
  class PublisherError < Exception
  end

  class Publisher

    def self.publish(topic, message)
      new.publish(topic, message)
    end

    def initialize
    end

    def publish(topic_id, message)
      raise PublisherError.new("Topic is nil") if topic_id.nil?
      raise PublisherError.new("Message is nil") if message.nil?

      topic_arn = TopicCreator.find_or_create(topic_id)
    end

    private

    def sns
      @sns ||= Fog::AWS::SNS.new(
        :aws_access_key_id => config.access_key,
        :aws_secret_access_key => config.secret_key,
        :region => config.queue_region
      )
    end
  end
end
