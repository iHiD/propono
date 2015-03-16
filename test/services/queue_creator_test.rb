require File.expand_path('../../test_helper', __FILE__)

module Propono
  class QueueCreatorTest < Minitest::Test

    def test_finds_existing_url
      name = "foobar"
      url = "http://#{name}"
      sqs = Fog::AWS::SQS::Mock.new
      sqs.stubs(:list_queues)
      sqs.expects(:list_queues).
        with("QueueNamePrefix" => "#{name}").
        returns(
          mock(body: { "QueueUrls" => [url]})
        )

      creator = QueueCreator.new(name)
      creator.stubs(sqs: sqs)

      queue = creator.find_or_create
      assert_equal url, queue.url
    end

    def test_create_queue_called_on_sqs
      sqs = Fog::AWS::SQS::Mock.new
      sqs.expects(:create_queue).with("foobar").returns(mock(body: { "QueueUrl" => "Foobar"}))

      creator = QueueCreator.new("foobar")
      creator.stubs(sqs: sqs)

      creator.find_or_create
    end

    def test_returns_url
      url = "malcs_happy_queue"
      result = mock(body: { "QueueUrl" => url})
      sqs = Fog::AWS::SQS::Mock.new
      sqs.expects(create_queue: result)

      creator = QueueCreator.new("foobar")
      creator.stubs(sqs: sqs)

      queue = creator.find_or_create
      assert_equal url, queue.url
    end

    def test_should_raise_exception_if_no_queue_returned
      result = mock(body: {})
      sqs = Fog::AWS::SQS::Mock.new
      sqs.expects(create_queue: result)

      creator = QueueCreator.new("foobar")
      creator.stubs(sqs: sqs)

      assert_raises QueueCreatorError do
        creator.find_or_create
      end
    end
  end
end

