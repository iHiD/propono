require 'socket'
require 'thread/future'

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
      Propono.config.logger.info "Propono: Publishing #{message} to #{topic_id} via #{protocol}"
      send("publish_via_#{protocol}")
    end

    private

    def publish_via_sns
      topic = TopicCreator.find_or_create(topic_id)
      msg = message.is_a?(String) ? message : message.to_json
      Thread.future(WORKER_POOL) do
        sns.publish(topic.arn, msg)
      end
    end

    def publish_via_udp
      payload = {topic: topic_id, message: message}.to_json
      UDPSocket.new.send(payload, 0, Propono.config.udp_host, Propono.config.udp_port)
    rescue => e
      Propono.config.logger.error "Propono failed to send : #{e}"
    end

    def publish_via_tcp
      payload = {topic: topic_id, message: message}.to_json

      socket = TCPSocket.new(Propono.config.tcp_host, Propono.config.tcp_port)
      socket.write payload
      socket.close
    rescue => e
      Propono.config.logger.error "Propono failed to send : #{e}"
    end
  end
end
