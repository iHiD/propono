module Propono

  module Subscriber
    def self.subscribe_by_queue(topic)
      QueueSubscriber.subscribe(topic)
    end

    def self.subscribe_by_post(topic, endpoint)
      PostSubscriber.subscribe(topic, endpoint)
    end
  end
end
