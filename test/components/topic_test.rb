require File.expand_path('../../test_helper', __FILE__)

module Propono
  class TopicTest < Minitest::Test
    def test_arn
      arn = 'foobar'
      aws_topic = mock
      aws_topic.expects(:topic_arn).returns(arn)
      topic = Topic.new(aws_topic)
      assert arn, topic.arn
    end
  end
end

