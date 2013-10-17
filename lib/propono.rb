require "propono/version"
require 'propono/configuration'
require 'propono/components/sns'
require 'propono/components/sqs'
require "propono/components/queue"
require "propono/components/topic"

require "propono/services/post_subscriber"
require "propono/services/publisher"
require "propono/services/queue_creator"
require "propono/services/queue_subscriber"
require "propono/services/subscriber"
require "propono/services/topic_creator"

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
