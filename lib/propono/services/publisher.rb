require 'socket'

module Propono
  class PublisherError < ProponoError
  end

  class Publisher
    include Sns

    def self.publish(*args)
      new(*args).publish
    end

    attr_reader :topic_id, :message, :id, :async

    def initialize(topic_id, message, async: false, id: nil)
      raise PublisherError.new("Topic is nil") if topic_id.nil?
      raise PublisherError.new("Message is nil") if message.nil?

      @topic_id = topic_id
      @message = message
      @async = async

      random_id = SecureRandom.hex(3)
      @id = id ? "#{id}-#{random_id}" : random_id
    end

    def publish
      Propono.config.logger.info "Propono [#{id}]: Publishing #{message} to #{topic_id}"
      async ? publish_asyncronously : publish_syncronously
    end

    private

    def publish_asyncronously
      Thread.new { publish_syncronously }
    end

    def publish_syncronously
      begin
        topic = TopicCreator.find_or_create(topic_id)
      rescue => e
        Propono.config.logger.error "Propono [#{id}]: Failed to create topic #{topic_id}: #{e}"
        raise
      end

      begin
        sns.publish(topic.arn, body.to_json)
      rescue => e
        Propono.config.logger.error "Propono [#{id}]: Failed to send via sns: #{e}"
        raise
      end
    end

    def body
      {
        id: id,
        message: message
      }
    end
  end
end
