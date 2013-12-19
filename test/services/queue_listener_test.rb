require File.expand_path('../../test_helper', __FILE__)

module Propono
  class QueueListenerTest < Minitest::Test

    def setup
      super
      @topic_id = "some-topic"

      @receipt_handle1 = "test-receipt-handle1"
      @receipt_handle2 = "test-receipt-handle2"
      @message1 = {cat: "Foobar 123"}
      @message2 = "Barfoo 543"
      @message1_id = "abc123"
      @message1_id = "987whf"
      @body1 = {id: @message1_id, message: @message1}
      @body2 = {id: @message2_id, message: @message2}
      @sqs_message1 = { "ReceiptHandle" => @receipt_handle1, "Body" => {"Message" => @body1.to_json}.to_json}
      @sqs_message2 = { "ReceiptHandle" => @receipt_handle2, "Body" => {"Message" => @body2.to_json}.to_json}
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
    
    def test_listen_raises_with_nil_topic
      listener = QueueListener.new(nil) {}
      assert_raises ProponoError do
        listener.listen
      end
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
    
    def test_log_message_from_sqs
      Propono.config.logger.expects(:info).with() {|x| x == "Propono [#{@message1_id}]: Received from sqs."}
      @listener.send(:read_messages)
    end
    
    def test_read_messages_calls_process_message_for_each_msg
      @listener.expects(:process_raw_message).with(@sqs_message1)
      @listener.expects(:process_raw_message).with(@sqs_message2)
      @listener.send(:read_messages)
    end
    
    def test_read_messages_does_not_call_process_messages_if_there_are_none
      @sqs_response.stubs(body: {"Message" => []})
      @listener.expects(:process_message).never
      @listener.send(:read_messages)
    end
    
    def test_exception_from_sqs_is_logged
      @listener.stubs(queue_url: "http://example.com")
      @sqs.stubs(:receive_message).raises(StandardError)
      Propono.config.logger.expects(:error).with("Unexpected error reading from queue http://example.com")
      Propono.config.logger.expects(:error).with() {|x| x.is_a?(StandardError)}
      @listener.send(:read_messages)
    end
    
    def test_forbidden_error_is_logged_and_re_raised
      @listener.stubs(queue_url: "http://example.com")
      @sqs.stubs(:receive_message).raises(Excon::Errors::Forbidden.new(nil, nil, nil))
      Propono.config.logger.expects(:error).with("Forbidden error caught and re-raised. http://example.com")
      Propono.config.logger.expects(:error).with() {|x| x.is_a?(Excon::Errors::Forbidden)}
      assert_raises Excon::Errors::Forbidden do
        @listener.send(:read_messages)
      end
    end
    
    def test_exception_from_sqs_returns_false
      @sqs.stubs(:receive_message).raises(StandardError)
      refute @listener.send(:read_messages)
    end
    
    def test_each_message_processor_is_yielded
      messages_yielded = []
      @listener = QueueListener.new(@topic_id) { |m, _| messages_yielded.push(m) }
      @listener.stubs(sqs: @sqs)
      @listener.send(:read_messages)
    
      assert_equal messages_yielded.size, 2
      assert messages_yielded.include?(@message1)
      assert messages_yielded.include?(@message2)
    end
    
    def test_each_message_processor_context
      contexts = []
      @listener = QueueListener.new(@topic_id) { |_, context| contexts << context }
      @listener.stubs(sqs: @sqs)
      @listener.send(:read_messages)
    
      assert_equal contexts.size, 2
      assert contexts.include?({id: @message1_id})
      assert contexts.include?({id: @message2_id})
    end
    
    def test_each_message_is_deleted
      queue_url = "test-queue-url"
    
      @sqs.expects(:delete_message).with(queue_url, @receipt_handle1)
      @sqs.expects(:delete_message).with(queue_url, @receipt_handle2)
    
      @listener.stubs(queue_url: queue_url)
      @listener.send(:read_messages)
    end
    
    def test_messages_are_deleted_if_there_is_an_exception_processing
      queue_url = "test-queue-url"
    
      @sqs.expects(:delete_message).with(queue_url, @receipt_handle1)
      @sqs.expects(:delete_message).with(queue_url, @receipt_handle2)
    
      exception = StandardError.new("Test Error") 
      @listener = QueueListener.new(@topic_id) { raise exception }
      @listener.stubs(queue_url: queue_url)
      @listener.stubs(sqs: @sqs)
      @listener.send(:read_messages)
    end
    
    def test_messages_are_moved_to_failed_queue_if_there_is_an_exception
      exception = StandardError.new("Test Error")
      @listener = QueueListener.new(@topic_id) { raise exception }
      @listener.expects(:move_to_failed_queue).with(SqsMessage.new(@sqs_message1), exception)
      @listener.expects(:move_to_failed_queue).with(SqsMessage.new(@sqs_message2), exception)
      @listener.stubs(sqs: @sqs)
      @listener.send(:read_messages)
    end
    
    def test_failed_on_moving_to_failed_queue_does_not_delete
      exception = StandardError.new("Test Error") 
      @listener = QueueListener.new(@topic_id) { raise exception }
      @listener.stubs(:move_to_failed_queue).with(SqsMessage.new(@sqs_message1)).raises(StandardError.new("failed to move"))
      @listener.stubs(:move_to_failed_queue).with(SqsMessage.new(@sqs_message2)).raises(StandardError.new("failed to move"))
      @listener.expects(:delete_message).with(@sqs_message1).never
      @listener.expects(:delete_message).with(@sqs_message2).never
      @listener.stubs(sqs: @sqs)
      @listener.send(:read_messages)
    end

    def test_messages_are_moved_to_corrupt_queue_if_there_is_an_parsing_exception
      sqs_message1 = "foobar"
      sqs_message2 = "barfoo"
      @messages["Message"][0] = sqs_message1
      @messages["Message"][1] = sqs_message2

      @listener.expects(:move_to_corrupt_queue).with(sqs_message1)
      @listener.expects(:move_to_corrupt_queue).with(sqs_message2)
      @listener.send(:read_messages)
    end

    def test_move_to_failed_queue
      QueueSubscription.expects(:create).with(@topic_id, queue_name_suffix: "-failed")
      Propono.expects(:publish).with("#{@topic_id}-failed", @message1, id: @message1_id)
      @listener.send(:move_to_failed_queue, SqsMessage.new(@sqs_message1), StandardError.new)
    end
    
    def test_move_to_corrupt_queue
      QueueSubscription.expects(:create).with(@topic_id, queue_name_suffix: "-corrupt")
      Propono.expects(:publish).with("#{@topic_id}-corrupt", @sqs_message1)
      @listener.send(:move_to_corrupt_queue, @sqs_message1)
    end
  end
end
