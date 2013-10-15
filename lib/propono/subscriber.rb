module Propono

  class Subscriber
    def self.subscribe(topic, type)
      new.subscribe(topic, type)
    end

    def subscribe(topic, type)
      if type == :queue
        subscribe_by_queue(topic)
      else
        subscribe_by_post(topic)
      end
    end

    def subscribe_by_queue(topic)
    end

    def subscribe_by_post(topic)
    end
  end

end
