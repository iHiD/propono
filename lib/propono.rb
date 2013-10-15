require "propono/version"
require 'propono/configuration'
require 'propono/sns'
require "propono/publisher"
require "propono/subscriber"
require "propono/topic_creator"

module Propono
  def config
    Configuration.instance
  end

  def publish(*args)
    Publisher.publish(*args)
  end

end
