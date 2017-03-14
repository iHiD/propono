require 'socket'

module Propono
  class PublisherError < ProponoError
  end

  class Publisher
    include Sns

    def self.publish(topic_id, message, options = {})
      new(topic_id, message, options).publish
    end

    attr_reader :topic_id, :message, :protocol, :id, :async

    def initialize(topic_id, message, options = {})
      raise PublisherError.new("Topic is nil") if topic_id.nil?
      raise PublisherError.new("Message is nil") if message.nil?

      options = Propono::Utils.symbolize_keys options

      @topic_id = topic_id
      @message = message
      @protocol = options.fetch(:protocol, :sns).to_sym
      @id = SecureRandom.hex(3)
      @id = "#{options[:id]}-#{@id}" if options[:id]
      @async = options.fetch(:async, true)
    end

    def publish
      Propono.config.logger.info "Propono [#{id}]: Publishing #{message} to #{topic_id} via #{protocol}"
      send("publish_via_#{protocol}")
    end

    private

    def publish_via_sns
      async ? publish_via_sns_asyncronously : publish_via_sns_syncronously
    end

    def publish_via_sns_asyncronously
      Thread.new { publish_via_sns_syncronously }
    end

    def publish_via_sns_syncronously
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
