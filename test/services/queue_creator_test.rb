require File.expand_path('../../test_helper', __FILE__)

module Propono
  class QueueCreatorTest < Minitest::Test

    def test_create_topic_called_on_sqs
      sqs = mock()
      sqs.expects(:create_queue).with("foobar").returns(mock(body: { "QueueUrl" => "Foobar"}))

      creator = QueueCreator.new("foobar")
      creator.stubs(sqs: sqs)

      creator.find_or_create
    end

    def test_returns_url
      url = "malcs_happy_queue"
      result = mock(body: { "QueueUrl" => url})
      sqs = mock(create_queue: result)

      creator = QueueCreator.new("foobar")
      creator.stubs(sqs: sqs)

      queue = creator.find_or_create
      assert_equal url, queue.url
    end

    def test_should_raise_exception_if_no_queue_returned
      result = mock(body: {})
      sqs = mock(create_queue: result)

      creator = QueueCreator.new("foobar")
      creator.stubs(sqs: sqs)

      assert_raises QueueCreatorError do
        creator.find_or_create
      end
    end
  end
end

