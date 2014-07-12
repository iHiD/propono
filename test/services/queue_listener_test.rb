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

      Propono.config.max_retries = 0
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

    def test_drain_should_continue_if_queue_empty
      @listener.expects(:read_messages).returns(nil)
      @listener.drain
      assert true
    end

    def test_drain_raises_with_nil_topic
      listener = QueueListener.new(nil) {}
      assert_raises ProponoError do
        listener.drain
      end
    end

    def test_read_messages_should_subscribe
      QueueSubscription.expects(create: mock(queue: mock(url: {})))
      @listener.send(:read_messages)
    end

    def test_read_message_from_sqs
      queue_url = @listener.send(:main_queue_url)
      options = { 'MaxNumberOfMessages' => 10 }
      @sqs.expects(:receive_message).with(queue_url, options).returns(@sqs_response)
      @listener.send(:read_messages_from_queue, queue_url, 10)
    end

    def test_log_message_from_sqs
      queue_url = @listener.send(:main_queue_url)
      Propono.config.logger.expects(:info).with() {|x| x == "Propono [#{@message1_id}]: Received from sqs."}
      @listener.send(:read_messages_from_queue, queue_url, 10)
    end

    def test_read_messages_calls_process_message_for_each_msg
      queue_url = @listener.send(:main_queue_url)
      @listener.expects(:process_raw_message).with(@sqs_message1, queue_url)
      @listener.expects(:process_raw_message).with(@sqs_message2, queue_url)
      @listener.send(:read_messages_from_queue, queue_url, 10)
    end

    def test_read_messages_does_not_call_process_messages_if_there_are_none
      queue_url = @listener.send(:main_queue_url)
      @sqs_response.stubs(body: {"Message" => []})
      @listener.expects(:process_message).never
      @listener.send(:read_messages_from_queue, queue_url, 10)
    end

    def test_exception_from_sqs_is_logged
      queue_url = "http://example.com"
      @listener.stubs(main_queue_url: queue_url)
      @sqs.stubs(:receive_message).raises(StandardError)
      Propono.config.logger.expects(:error).with("Unexpected error reading from queue http://example.com")
      Propono.config.logger.expects(:error).with() {|x| x.is_a?(StandardError)}
      @listener.send(:read_messages_from_queue, queue_url, 10)
    end

    def test_forbidden_error_is_logged_and_re_raised
      queue_url = "http://example.com"
      @listener.stubs(queue_url: queue_url)
      @sqs.stubs(:receive_message).raises(Excon::Errors::Forbidden.new(nil, nil, nil))
      Propono.config.logger.expects(:error).with("Forbidden error caught and re-raised. http://example.com")
      Propono.config.logger.expects(:error).with() {|x| x.is_a?(Excon::Errors::Forbidden)}
      assert_raises Excon::Errors::Forbidden do
        @listener.send(:read_messages_from_queue, queue_url, 10)
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
      @listener.send(:read_messages_from_queue, queue_url, 10)
    end

    def test_messages_are_deleted_if_there_is_an_exception_processing
      queue_url = "test-queue-url"

      @sqs.expects(:delete_message).with(queue_url, @receipt_handle1)
      @sqs.expects(:delete_message).with(queue_url, @receipt_handle2)

      exception = StandardError.new("Test Error")
      @listener = QueueListener.new(@topic_id) { raise exception }
      @listener.stubs(queue_url: queue_url)
      @listener.stubs(sqs: @sqs)
      @listener.stubs(:requeue_message_on_failure).with(SqsMessage.new(@sqs_message1), exception)
      @listener.stubs(:requeue_message_on_failure).with(SqsMessage.new(@sqs_message2), exception)
      @listener.send(:read_messages_from_queue, queue_url, 10)
    end

    def test_messages_are_retried_or_abandoned_on_failure
      queue_url = "test-queue-url"

      exception = StandardError.new("Test Error")
      @listener = QueueListener.new(@topic_id) { raise exception }
      @listener.expects(:requeue_message_on_failure).with(SqsMessage.new(@sqs_message1), exception)
      @listener.expects(:requeue_message_on_failure).with(SqsMessage.new(@sqs_message2), exception)
      @listener.stubs(sqs: @sqs)
      @listener.send(:read_messages_from_queue, queue_url, 10)
    end

    def test_failed_on_moving_to_failed_queue_does_not_delete
      queue_url = "test-queue-url"

      exception = StandardError.new("Test Error")
      @listener = QueueListener.new(@topic_id) { raise exception }
      @listener.stubs(:requeue_message_on_failure).with(SqsMessage.new(@sqs_message1), exception).raises(StandardError.new("failed to move"))
      @listener.stubs(:requeue_message_on_failure).with(SqsMessage.new(@sqs_message2), exception).raises(StandardError.new("failed to move"))
      @listener.expects(:delete_message).with(@sqs_message1).never
      @listener.expects(:delete_message).with(@sqs_message2).never
      @listener.stubs(sqs: @sqs)
      @listener.send(:read_messages_from_queue, queue_url, 10)
    end

    def test_messages_are_moved_to_corrupt_queue_if_there_is_an_parsing_exception
      queue_url = "test-queue-url"
      sqs_message1 = "foobar"
      sqs_message2 = "barfoo"
      @messages["Message"][0] = sqs_message1
      @messages["Message"][1] = sqs_message2

      @listener.expects(:move_to_corrupt_queue).with(sqs_message1)
      @listener.expects(:move_to_corrupt_queue).with(sqs_message2)
      @listener.send(:read_messages_from_queue, queue_url, 10)
    end

    def test_message_moved_to_failed_queue_if_there_is_an_exception_and_retry_count_is_zero
      @sqs.expects(:send_message).with(regexp_matches(/https:\/\/queue.amazonaws.com\/[0-9]+\/MyApp-some-topic-failed/), anything)
      @listener.send(:requeue_message_on_failure, SqsMessage.new(@sqs_message1), StandardError.new)
    end

    def test_message_requeued_if_there_is_an_exception_but_failure_count_less_than_retry_count
      Propono.config.max_retries = 5
      message = SqsMessage.new(@sqs_message1)
      message.stubs(failure_count: 4)
      @sqs.expects(:send_message).with(regexp_matches(/https:\/\/queue.amazonaws.com\/[0-9]+\/MyApp-some-topic$/), anything)
      @listener.send(:requeue_message_on_failure, message, StandardError.new)
    end

    def test_message_requeued_if_there_is_an_exception_but_failure_count_exceeds_than_retry_count
      Propono.config.max_retries = 5
      message = SqsMessage.new(@sqs_message1)
      message.stubs(failure_count: 5)
      @sqs.expects(:send_message).with(regexp_matches(/https:\/\/queue.amazonaws.com\/[0-9]+\/MyApp-some-topic-failed/), anything)
      @listener.send(:requeue_message_on_failure, message, StandardError.new)
    end

    def test_move_to_corrupt_queue
      @sqs.expects(:send_message).with(regexp_matches(/https:\/\/queue.amazonaws.com\/[0-9]+\/MyApp-some-topic-corrupt/), anything)
      @listener.send(:move_to_corrupt_queue, @sqs_message1)
    end

    def test_if_no_messages_read_from_normal_queue_read_from_slow_queue
      main_queue_url = "http://normal.com"
      @listener.stubs(main_queue_url: main_queue_url)
      slow_queue_url = "http://slow.com"
      @listener.stubs(slow_queue_url: slow_queue_url)

      @listener.expects(:read_messages_from_queue).with(main_queue_url, 10).returns(false)
      @listener.expects(:read_messages_from_queue).with(slow_queue_url, 1)
      @listener.send(:read_messages)
    end

    def test_if_read_messages_from_normal_do_not_read_from_slow_queue
      main_queue_url = "http://normal.com"
      @listener.stubs(main_queue_url: main_queue_url)

      @listener.expects(:read_messages_from_queue).with(main_queue_url, 10).returns(true)
      @listener.send(:read_messages)
    end
  end
end
