module Propono
  class QueueSubscription

    include Sns
    include Sqs

    attr_reader :topic_arn, :queue

    def self.create(topic_id)
      new(topic_id).tap do |subscription|
        subscription.create
      end
    end

    def initialize(topic_id)
      @topic_id = topic_id
    end

    def create
      @topic = TopicCreator.find_or_create(@topic_id)
      @queue = QueueCreator.find_or_create(queue_name)
      sns.subscribe(@topic.arn, @queue.arn, 'sqs')
    end

    def queue_name
      @queue_name ||= "#{config.application_name.gsub(" ", "_")}-#{@topic_id}"
    end

    private

    def config
      Configuration.instance
    end
  end
end
