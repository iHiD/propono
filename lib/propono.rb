require "propono/version"
require 'propono/configuration'
require 'propono/sns'
require 'propono/sqs'
require "propono/post_subscriber"
require "propono/publisher"
require "propono/queue"
require "propono/queue_creator"
require "propono/queue_subscriber"
require "propono/subscriber"
require "propono/topic_creator"

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

end
