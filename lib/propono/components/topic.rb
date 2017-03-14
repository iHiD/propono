module Propono
  class Topic
    attr_reader :aws_topic
    def initialize(aws_topic)
      @aws_topic = aws_topic
    end

    def arn
      @arn ||= aws_topic.topic_arn
    end
  end
end
