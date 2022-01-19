require 'socket'

module Propono
  class PublisherError < ProponoError
  end

  class Publisher
    def self.publish(aws_client, propono_config, topic_name, message, options={})
      new(aws_client, propono_config, topic_name, message, **options).publish
    end

    attr_reader :aws_client, :propono_config, :topic_name, :message, :id, :async

    def initialize(aws_client, propono_config, topic_name, message, async: false, id: nil)
      raise PublisherError.new("Topic is nil") if topic_name.nil?
      raise PublisherError.new("Message is nil") if message.nil?

      @aws_client = aws_client
      @propono_config = propono_config
      @topic_name = topic_name
      @message = message
      @async = async

      random_id = SecureRandom.hex(3)
      @id = id ? "#{id}-#{random_id}" : random_id
    end

    def publish
      propono_config.logger.info "Propono [#{id}]: Publishing #{message} to #{topic_name}"
      async ? publish_asyncronously : publish_syncronously
    end

    private

    def publish_asyncronously
      Thread.new { publish_syncronously }
    end

    def publish_syncronously
      begin
        topic = aws_client.create_topic(topic_name)
      rescue => e
        propono_config.logger.error "Propono [#{id}]: Failed to get or create topic #{topic_name}: #{e}"
        raise
      end

      begin
        aws_client.publish_to_sns(topic, body)
      rescue => e
        propono_config.logger.error "Propono [#{id}]: Failed to send via sns: #{e}"
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
