module Propono
  class PublisherError < ProponoError
  end

  class Publisher
    include Sns

    def self.publish(topic_id, message, options = {})
      new(topic_id, message, options).publish
    end

    attr_reader :topic_id, :message, :protocol

    def initialize(topic_id, message, options = {})
      raise PublisherError.new("Topic is nil") if topic_id.nil?
      raise PublisherError.new("Message is nil") if message.nil?

      @topic_id = topic_id
      @message = message
      @protocol = options.fetch(:protocol, :sns).to_sym
    end

    def publish
      send("publish_via_#{protocol}")
    end

    private

    def publish_via_sns
      topic = TopicCreator.find_or_create(topic_id)
      msg = message.is_a?(String) ? message : message.to_json
      sns.publish(topic.arn, msg)
    end

    def publish_via_udp
      payload = {topic: topic_id, message: message}.to_json
      UDPSocket.new.send(payload, 0, config.udp_host, config.udp_port)
    rescue SocketError => e
      config.logger.puts "Udp2sqs failed to send : #{e}"
    end

    def config
      Configuration.instance
    end
  end
end
