require "propono/version"
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

module Propono
  def self.config
    Configuration.instance
  end

  def self.publish(*args)
    Publisher.publish(*args)
  end

  def self.subscribe_by_queue(*args)
    Subscriber.subscribe_by_queue(*args)
  end

  def self.subscribe_by_post(*args)
    Subscriber.subscribe_by_post(*args)
  end

  def self.listen_to_queue(*args, &block)
    QueueListener.listen(*args, &block)
  end

  def self.listen_to_sqs(*args, &block)
    UdpListener.listen(*args, &block)
  end
end
