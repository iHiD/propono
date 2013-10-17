require File.expand_path('../test_helper', __FILE__)

module Propono
  class TopicTest < Minitest::Test
    def test_intialization_sets_url
      arn = 'foobar'
      topic = Topic.new(arn)
      assert arn, topic.arn
    end
  end
end

