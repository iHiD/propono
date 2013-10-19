require File.expand_path('../../test_helper', __FILE__)

module Propono
  class QueueListenerTest < Minitest::Test

    def setup
      super
      @topic_id = "some-topic"

      @receipt_handle1 = "test-receipt-handle1"
      @receipt_handle2 = "test-receipt-handle2"
      @message1 = "Foobar 123"
      @message2 = "Barfoo 543"
      @sqs_message1 = { "ReceiptHandle" => @receipt_handle1, "Body" => {"Message" => @message1}.to_json}
      @sqs_message2 = { "ReceiptHandle" => @receipt_handle2, "Body" => {"Message" => @message2}.to_json}
      @messages = { "Message" => [ @sqs_message1, @sqs_message2 ] }
      @sqs_response = mock().tap{|m|m.stubs(body: @messages)}
      @sqs = mock()
      @sqs.stubs(receive_message: @sqs_response)
      @sqs.stubs(:delete_message)

      @listener = QueueListener.new(@topic_id) {}
      @listener.stubs(sqs: @sqs)
    end

    def test_listen_should_loop
      @listener.expects(:loop)
      @listener.listen
    end

    def test_read_messages_should_subscribe
      QueueSubscription.expects(create: mock(queue: mock(url: {})))
      @listener.send(:read_messages)
    end

    def test_read_message_from_sqs
      queue_url = @listener.send(:queue_url)
      options = { 'MaxNumberOfMessages' => 10 }
      @sqs.expects(:receive_message).with(queue_url, options).returns(@sqs_response)
      @listener.send(:read_messages)
    end

    def test_read_messages_calls_process_message_for_each_msg
      @listener.expects(:process_sqs_message).with(@sqs_message1)
      @listener.expects(:process_sqs_message).with(@sqs_message2)
      @listener.send(:read_messages)
    end

    def test_read_messages_does_not_call_process_messages_if_there_are_none
      @sqs_response.stubs(body: {"Message" => []})
      @listener.expects(:process_sqs_message).never
      @listener.send(:read_messages)
    end

    def test_exception_from_sqs_is_logged
      @listener.stubs(queue_url: "http://example.com")
      @sqs.stubs(:receive_message).raises(StandardError)
      out, err = capture_io do
        @listener.send(:read_messages)
      end
      assert_equal "Unexpected error reading from queue http://example.com\nStandardError\n", err
    end

    def test_exception_from_sqs_returns_false
      @sqs.stubs(:receive_message).raises(StandardError)
      refute @listener.send(:read_messages)
    end

    def test_each_message_processor_is_yielded
      messages_yielded = [ ]
      @listener = QueueListener.new(@topic_id) { |m| messages_yielded.push(m) }
      @listener.stubs(sqs: @sqs)

      @listener.send(:read_messages)

      assert_equal messages_yielded.size, 2
      assert messages_yielded.include?(@message1)
      assert messages_yielded.include?(@message2)
    end

    def test_each_message_is_deleted
      queue_url = "test-queue-url"

      @sqs.expects(:delete_message).with(queue_url, @receipt_handle1)
      @sqs.expects(:delete_message).with(queue_url, @receipt_handle2)

      @listener.stubs(queue_url: queue_url)
      @listener.send(:read_messages)
    end
  end
end
