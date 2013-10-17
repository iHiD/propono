module Propono
  class PostSubscriber
    include Sns

    def self.subscribe(topic, endpoint)
      new(topic, endpoint).subscribe
    end

    def initialize(topic_id, endpoint)
      @topic_id = topic_id
      @endpoint = endpoint
    end

    def subscribe
      topic_arn = TopicCreator.find_or_create(@topic_id)
      sns.subscribe(topic_arn, @endpoint, 'http')
    end
  end
end
