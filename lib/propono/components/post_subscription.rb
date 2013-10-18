module Propono
  class PostSubscription
    include Sns

    def self.create(topic, endpoint)
      new(topic, endpoint).create
    end

    def initialize(topic_id, endpoint)
      @topic_id = topic_id
      @endpoint = endpoint
    end

    def create
      topic_arn = TopicCreator.find_or_create(@topic_id)
      sns.subscribe(topic_arn, @endpoint, 'http')
    end
  end
end
