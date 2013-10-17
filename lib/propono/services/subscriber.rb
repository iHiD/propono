module Propono

  module Subscriber
    def self.subscribe_by_queue(topic)
      QueueSubscription.create(topic)
    end

    def self.subscribe_by_post(topic, endpoint)
      PostSubscription.create(topic, endpoint)
    end
  end
end
