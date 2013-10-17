require File.expand_path('../test_helper', __FILE__)

module Propono
  class TopicCreatorTest < Minitest::Test

    def test_create_topic_called_on_sns
      sns = mock()
      sns.expects(:create_topic).with("foobar").returns(mock(body: { "TopicArn" => @arn}))

      creator = TopicCreator.new("foobar")
      creator.stubs(sns: sns)

      creator.find_or_create
    end

    def test_returns_arn
      arn = "malcs_happy_arn"
      result = mock(body: { "TopicArn" => arn})
      sns = mock(create_topic: result)

      creator = TopicCreator.new("foobar")
      creator.stubs(sns: sns)

      topic = creator.find_or_create
      assert_equal arn, topic.arn
    end

    def test_should_raise_exception_if_no_arn_returned
      result = mock(body: {})
      sns = mock(create_topic: result)

      creator = TopicCreator.new("foobar")
      creator.stubs(sns: sns)

      assert_raises TopicCreatorError do
        creator.find_or_create
      end
    end
  end
end
