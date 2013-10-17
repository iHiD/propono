module Propono
  class QueueSubscriber

    include Sns
    include Sqs

    attr_reader :topic_arn, :queue

    def self.subscribe(topic_id)
      new(topic_id).subscribe
    end

    def initialize(topic_id)
      @topic_id = topic_id
    end

    def subscribe
      @topic = TopicCreator.find_or_create(@topic_id)
      @queue = QueueCreator.find_or_create(queue_name)
      sns.subscribe(@topic.arn, @queue.arn, 'sqs')
    end

    private

    def queue_name
      @topic_id
    end
  end
end
