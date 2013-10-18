require File.expand_path('../test_helper', __FILE__)

module Propono
  class QueueListenerTest < Minitest::Test

    def setup
      super
      @topic_id = "some-topic"

      @receipt_handle1 = "test-receipt-handle1"
      @receipt_handle2 = "test-receipt-handle2"
      @message1 = { "ReceiptHandle" => @receipt_handle1}
      @message2 = { "ReceiptHandle" => @receipt_handle2}
      @messages = { "Message" => [ @message1, @message2 ] }
    end

    def test_read_message_from_sqs
      message_response = mock()
      messages = { "Message" => [ { "ReceiptHandle" => "test-receipt-handle"} ] }
      message_response.expects(:body).returns(messages)
      sqs = mock()
      sqs.stubs(delete_message: message_response)

      sqs.expects(:receive_message).returns(message_response)

      queue_listener = QueueListener.new(@topic_id) {}
      queue_listener.stubs(sqs: sqs)

      queue_listener.send(:read_messages)
    end

    def test_each_message_yielded
      message_response = mock()
      message_response.expects(:body).returns(@messages)
      sqs = mock()
      sqs.stubs(receive_message: message_response)

      sqs.expects(:delete_message).with(@receipt_handle1)
      sqs.expects(:delete_message).with(@receipt_handle2)

      queue_listener = QueueListener.new(@topic_id) { }
      queue_listener.stubs(sqs: sqs)

      queue_listener.send(:read_messages)
    end

    def test_each_message_deleted_from_sqs
      message_response = mock()
      message_response.expects(:body).returns(@messages)
      sqs = mock()
      sqs.stubs(delete_message: message_response)
      sqs.stubs(receive_message: message_response)

      messages_yielded = [ ]
      queue_listener = QueueListener.new(@topic_id) { |m| messages_yielded.push(m) }
      queue_listener.stubs(sqs: sqs)

      queue_listener.send(:read_messages)

      assert_equal messages_yielded.size, 2
      assert messages_yielded.include?(@message1)
      assert messages_yielded.include?(@message2)
    end

    def test_empty_list_of_messages_returned
      message_response = mock()
      messages = { "Message" => [ ] }
      message_response.expects(:body).returns(messages)
      sqs = mock()
      sqs.stubs(delete_message: message_response)

      sqs.expects(:receive_message).returns(message_response)

      queue_listener = QueueListener.new(@topic_id) {}
      queue_listener.stubs(sqs: sqs)

      refute queue_listener.send(:read_messages)
    end

    def test_exception_from_sqs_is_logged
      sqs = mock()
      sqs.stubs(:receive_message).raises(StandardError)

      queue_listener = QueueListener.new(@topic_id) {}
      queue_listener.stubs(sqs: sqs)
      queue_listener.stubs(queue_url: "http://example.com")

      out, err = capture_io do
        queue_listener.send(:read_messages)
      end
      assert_equal "Unexpected error reading from queue http://example.com\n", err
    end

    def test_exception_from_sqs_returns_false
      sqs = mock()
      sqs.stubs(:receive_message).raises(StandardError)

      queue_listener = QueueListener.new(@topic_id) {}
      queue_listener.stubs(sqs: sqs)

      refute queue_listener.send(:read_messages)
    end

    def test_listen_should_loop
      listener = QueueListener.new(@topic_id)
      listener.expects(:loop)
      listener.listen
    end

    def test_read_messages_should_subscribe
      listener = QueueListener.new(@topic_id)
      QueueSubscription.expects(create: mock(queue: mock(url: {})))
      listener.send(:read_messages)
    end
  end
end
