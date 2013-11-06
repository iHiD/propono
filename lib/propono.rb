# Propono
#
# Propono is a pub/sub gem built on top of Amazon Web Services (AWS). It uses Simple Notification Service (SNS) and Simple Queue Service (SQS) to seamlessly pass messages throughout your infrastructure.

require "propono/version"
require 'propono/propono_error'
require 'propono/logger'
require 'propono/configuration'

require 'propono/components/sns'
require 'propono/components/sqs'
require "propono/components/queue"
require "propono/components/topic"
require "propono/components/post_subscription"
require "propono/components/queue_subscription"

require "propono/services/publisher"
require "propono/services/queue_creator"
require "propono/services/queue_listener"
require "propono/services/subscriber"
require "propono/services/topic_creator"
require "propono/services/udp_listener"
require "propono/services/tcp_listener"

# Propono is a pub/sub gem built on top of Amazon Web Services (AWS).
# It uses Simple Notification Service (SNS) and Simple Queue Service (SQS)
# to seamlessly pass messages throughout your infrastructure.
module Propono

  # Propono configuration settings.
  #
  # Settings should be set in an initializer or using some
  # other method that insures they are set before any
  # Propono code is used. They can be set as followed:
  #
  #   Propono.config.access_key = "my-access-key"
  #
  # The following settings are allowed:
  #
  # * <tt>:access_key</tt> - The AWS access key
  # * <tt>:secret_key</tt> - The AWS secret key
  # * <tt>:queue_region</tt> - The AWS region
  # * <tt>:application_name</tt> - The name of the application Propono
  #   is included in.
  # * <tt>:udp_host</tt> - If using UDP, the host to send to.
  # * <tt>:udp_port</tt> - If using UDP, the port to send to.
  # * <tt>:logger</tt> - A logger object that responds to puts.
  def self.config
    @config ||= Configuration.new
    if block_given?
      yield @config
    else
      @config
    end
  end

  # Publishes a new message into the Propono pub/sub network.
  #
  # This requires a topic and a message. By default this pushes
  # out AWS SNS. The method optionally takes a :protocol key in
  # options, which can be set to :udp for non-guaranteed but very
  # fast delivery.
  #
  # @param [String] topic The name of the topic to publish to.
  # @param [String] message The message to post.
  # @param [Hash] options
  #   * protocol: :udp
  def self.publish(topic, message, options = {})
    Publisher.publish(topic, message, options)
  end

  # Creates a new SNS-SQS subscription on the specified topic.
  #
  # This is implicitly called by {#listen_to_queue}.
  #
  # @param [String] topic The name of the topic to subscribe to.
  def self.subscribe_by_queue(topic)
    Subscriber.subscribe_by_queue(topic)
  end

  # Creates a new SNS-POST subscription on the specified topic.
  #
  # The POST currently needs confirming before the subscription
  # can be published to.
  #
  # @param [String] topic The name of the topic to subscribe to.
  def self.subscribe_by_post(topic, endpoint)
    Subscriber.subscribe_by_post(topic, endpoint)
  end

  # Listens on a queue and yields for each message
  #
  # Calling this will enter a queue-listening loop that
  # yields the message_processor for each messages.
  #
  # This method will automatically create a subscription if
  # one does not exist, so there is no need to call
  # <tt>subscribe_by_queue</tt> in addition.
  #
  # @param [String] topic The topic to subscribe to.
  # @param &message_processor The block to yield for each message.
  def self.listen_to_queue(topic, &message_processor)
    QueueListener.listen(topic, &message_processor)
  end

  # Listens for UDP messages and yields for each.
  #
  # Calling this will enter a queue-listening loop that
  # yields the message_processor for each UDP message received.
  #
  # @param &message_processor The block to yield for each message.
  #   Is called with <tt>|topic, message|</tt>.
  def self.listen_to_udp(&message_processor)
    UdpListener.listen(&message_processor)
  end

  # Listens for TCP messages and yields for each.
  #
  # Calling this will enter a queue-listening loop that
  # yields the message_processor for each UDP message received.
  #
  # @param &message_processor The block to yield for each message.
  #   Is called with <tt>|topic, message|</tt>.
  def self.listen_to_tcp(&message_processor)
    TcpListener.listen(&message_processor)
  end

  # Listens for UDP messages and passes them onto the queue.
  #
  # This method uses #listen_to_udp and #publish to proxy
  # messages from UDP onto the queue.
  def self.proxy_udp
    Propono.listen_to_udp do |topic, message|
      Propono.publish(topic, message)
    end
  end

  # Listens for TCP messages and passes them onto the queue.
  #
  # This method uses #listen_to_tcp and #publish to proxy
  # messages from TCP onto the queue.
  def self.proxy_tcp
    Propono.listen_to_tcp do |topic, message|
      Propono.publish(topic, message)
    end
  end
end
