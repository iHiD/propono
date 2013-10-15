require 'fog'

module Propono
  class TopicCreatorError < Exception
  end

  class TopicCreator
    def self.find_or_create(topic_id)
      new(topic_id).find_or_create
    end

    def initialize(topic_id)
      @topic_id = topic_id
    end

    def find_or_create
      create_topic_result = sns.create_topic(@topic_id)
      body = create_topic_result.body
      body.fetch('TopicArn') { raise TopicCreatorError.new("No TopicArn returned from SNS") }
    end

    private

    def sns
      raise "Foobar"
      @sns ||= Fog::AWS::SNS.new(
        :aws_access_key_id => config.access_key,
        :aws_secret_access_key => config.secret_key,
        :region => config.queue_region
      )
    end
  end
end
