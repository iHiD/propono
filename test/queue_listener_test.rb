require File.expand_path('../test_helper', __FILE__)

module Propono
  class QueueListenerTest < Minitest::Test

    def setup
      @queue_url = "http://example.com"

      @receipt_hanlde1 = "test-receipt-handle1"
      @receipt_hanlde2 = "test-receipt-handle2"
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

      queueListener = QueueListener.new(@queue_url) {}
      queueListener.stubs(sqs: sqs)

      queueListener.send(:read_messages)
    end

    def test_each_message_yielded
      message_response = mock()
      message_response.expects(:body).returns(@messages)
      sqs = mock()
      sqs.stubs(receive_message: message_response)

      sqs.expects(:delete_message).with(@receipt_handle1)
      sqs.expects(:delete_message).with(@receipt_handle2)

      queueListener = QueueListener.new(@queue_url) { }
      queueListener.stubs(sqs: sqs)

      queueListener.send(:read_messages)
    end

    def test_each_message_deleted_from_sqs
      message_response = mock()
      message_response.expects(:body).returns(@messages)
      sqs = mock()
      sqs.stubs(delete_message: message_response)
      sqs.stubs(receive_message: message_response)

      messages_yielded = [ ]
      queueListener = QueueListener.new(@queue_url) { |m| messages_yielded.push(m) }
      queueListener.stubs(sqs: sqs)

      queueListener.send(:read_messages)

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

      queueListener = QueueListener.new(@queue_url) {}
      queueListener.stubs(sqs: sqs)

      refute queueListener.send(:read_messages)
    end

    def test_exception_from_sqs_is_logged
      sqs = mock()
      sqs.stubs(:receive_message).raises(StandardError)

      queueListener = QueueListener.new(@queue_url) {}
      queueListener.stubs(sqs: sqs)

      # capture_io reasigns stderr. Assign the config.logger
      # to where capture_io has redirected it to for this test.
      out, err = capture_io do
        config.logger = $stderr
        queueListener.send(:read_messages)
      end
      # Reassign config.logger to the correct stderr
      config.logger = $stderr
      assert_equal "Unexpected error reading from queue http://example.com\n", err
    end

  end
end
