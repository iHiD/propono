module Propono
  class TopicCreatorError < Exception
  end

  class TopicCreator
    include Sns

    def self.find_or_create(topic_id)
      new(topic_id).find_or_create
    end

    def initialize(topic_id)
      @topic_id = topic_id
    end

    def find_or_create
      result = sns.create_topic(@topic_id)
      body = result.body
      arn = body.fetch('TopicArn') { raise TopicCreatorError.new("No TopicArn returned from SNS") }
      Topic.new(arn)
    end
  end
end
