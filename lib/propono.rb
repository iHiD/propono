# Propono
#
# Propono is a pub/sub gem built on top of Amazon Web Services (AWS). It uses Simple Notification Service (SNS) and Simple Queue Service (SQS) to seamlessly pass messages throughout your infrastructure.
require "propono/version"
require 'propono/propono_error'
require 'propono/logger'
require 'propono/configuration'
require "propono/utils"

require 'propono/components/aws_config'
require 'propono/components/aws_client'

require 'propono/components/sns'
require 'propono/components/sqs'
require "propono/components/queue"
require "propono/components/topic"
require "propono/components/queue_subscription"
require "propono/components/sqs_message"

require "propono/services/publisher"
require "propono/services/queue_creator"
require "propono/services/queue_listener"
require "propono/services/subscriber"

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
  # * <tt>:queue_suffix</tt> - Optional string to append to topic and queue names.
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
  # out AWS SNS.
  #
  # @param [String] topic The name of the topic to publish to.
  # @param [String] message The message to post.
  def self.publish(topic, message, options = {})
    suffixed_topic = "#{topic}#{Propono.config.queue_suffix}"
    Publisher.publish(suffixed_topic, message, options)
  end

  # Creates a new SNS-SQS subscription on the specified topic.
  #
  # This is implicitly called by {#listen_to_queue}.
  #
  # @param [String] topic The name of the topic to subscribe to.
  def self.subscribe(topic)
    QueueSubscription.create(topic)
  end

  # Listens on a queue and yields for each message
  #
  # Calling this will enter a queue-listening loop that
  # yields the message_processor for each messages.
  #
  # This method will automatically create a subscription if
  # one does not exist, so there is no need to call
  # <tt>subscribe</tt> in addition.
  #
  # @param [String] topic The topic to subscribe to.
  # @param &message_processor The block to yield for each message.
  def self.listen_to_queue(topic, &message_processor)
    QueueListener.listen(topic, &message_processor)
  end

  # Listens on a queue and yields for each message
  #
  # Calling this will enter a queue-listening loop that
  # yields the message_processor for each messages.  The
  # loop will end when all messages have been processed.
  #
  # This method will automatically create a subscription if
  # one does not exist, so there is no need to call
  # <tt>subscribe</tt> in addition.
  #
  # @param [String] topic The topic to subscribe to.
  # @param &message_processor The block to yield for each message.
  def self.drain_queue(topic, &message_processor)
    QueueListener.drain(topic, &message_processor)
  end
end
