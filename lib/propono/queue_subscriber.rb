module Propono
  class QueueSubscriber

    include Sns

    def self.subscribe(topic_id)
      new(topic_id).subscribe
    end

    def initialize(topic_id)
      @topic_id = topic_id
    end

    def subscribe
      topic_arn = TopicCreator.find_or_create(@topic_id)
      queue_url = QueueCreator.find_or_create(queue_name)
      sns.subscribe(topic_arn, queue_url, 'sqs')
      queue_url
    end

    private

    def queue_name
      @topic_id
    end
  end
end
