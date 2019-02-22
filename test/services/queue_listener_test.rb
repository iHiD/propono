require File.expand_path('../../test_helper', __FILE__)

module Propono
  class QueueListenerTest < Minitest::Test

    def setup
      super
      @topic_name = "some-topic"

      @receipt_handle1 = "test-receipt-handle1"
      @receipt_handle2 = "test-receipt-handle2"
      @message1 = {cat: "Foobar 123"}
      @message2 = "Barfoo 543"
      @message1_id = "abc123"
      @message2_id = "987whf"
      @body1 = {id: @message1_id, message: @message1}
      @body2 = {id: @message2_id, message: @message2}

      @sqs_message1 = mock
      @sqs_message1.stubs(receipt_handle: @receipt_handle1, body: {"Message" => @body1.to_json}.to_json)
      @sqs_message2 = mock
      @sqs_message2.stubs(receipt_handle: @receipt_handle2, body: {"Message" => @body2.to_json}.to_json)

      @queue = mock.tap {|q| q.stubs(url: "foobar", arn: "qarn") }
      @topic = mock.tap {|t| t.stubs(arn: "tarn") }
      aws_client.stubs(
        create_queue: @queue,
        create_topic: @topic
      )
      aws_client.stubs(:subscribe_sqs_to_sns)
      aws_client.stubs(:set_sqs_policy)

      @messages = [@sqs_message1, @sqs_message2]
      aws_client.stubs(read_from_sqs: @messages)
      aws_client.stubs(:delete_from_sqs)

      @listener = QueueListener.new(aws_client, propono_config, @topic_name) {}

      @slow_queue = mock
      @slow_queue.stubs(url: "some_queue_url")
      @failed_queue = mock
      @corrupt_queue = mock
      @listener.stubs(slow_queue: @slow_queue, corrupt_queue: @corrupt_queue, failed_queue: @failed_queue)

      propono_config.num_messages_per_poll = 14
      propono_config.max_retries = 0
    end

    def test_listen_should_loop
      @listener.expects(:loop)
      @listener.listen
    end

    def test_listen_raises_with_nil_topic
      listener = QueueListener.new(aws_client, propono_config, nil) {}
      assert_raises ProponoError do
        listener.listen
      end
    end

    def test_drain_should_continue_if_queue_empty
      @listener.expects(:read_messages_from_queue).with(@slow_queue, 10, long_poll: false).returns(false)
      @listener.expects(:read_messages_from_queue).with(@queue, 10, long_poll: false).returns(false)
      @listener.drain
      assert true
    end

    def test_drain_raises_with_nil_topic
      listener = QueueListener.new(aws_client, propono_config, nil) {}
      assert_raises ProponoError do
        listener.drain
      end
    end

    def test_read_messages_should_subscribe
      queue = mock
      queue.stubs(:url)
      QueueSubscription.expects(:create).with(aws_client, propono_config, @topic_name).returns(mock(queue: queue))
      @listener.send(:read_messages)
    end

    def test_read_message_from_sqs
      max_number_of_messages = 5
      aws_client.expects(:read_from_sqs).with(@queue, max_number_of_messages, long_poll: true, visibility_timeout: nil)
      @listener.send(:read_messages_from_queue, @queue, max_number_of_messages)
    end

    def test_log_message_from_sqs
      propono_config.logger.expects(:info).with() {|x| x == "Propono [#{@message1_id}]: Received from sqs."}
      @listener.send(:read_messages_from_queue, @queue, propono_config.num_messages_per_poll)
    end

    def test_read_messages_calls_process_message_for_each_msg
      @listener.expects(:process_raw_message).with(@sqs_message1, @queue)
      @listener.expects(:process_raw_message).with(@sqs_message2, @queue)
      @listener.send(:read_messages_from_queue, @queue, propono_config.num_messages_per_poll)
    end

    def test_read_messages_does_not_call_process_messages_if_there_are_none
      aws_client.stubs(read_from_sqs: [])
      @listener.expects(:process_message).never
      @listener.send(:read_messages_from_queue, @queue, propono_config.num_messages_per_poll)
    end

    def test_exception_from_sqs_is_logged
      aws_client.stubs(:read_from_sqs).raises(StandardError)
      propono_config.logger.expects(:error).with("Unexpected error reading from queue #{@queue.url}")
      @listener.send(:read_messages_from_queue, @queue, propono_config.num_messages_per_poll)
    end

    def test_exception_from_sqs_returns_false
      aws_client.stubs(:read_from_sqs).raises(StandardError)
      refute @listener.send(:read_messages)
    end

    def test_each_message_processor_is_yielded
      messages_yielded = []
      @listener = QueueListener.new(aws_client, propono_config, @topic_name) { |m, _| messages_yielded.push(m) }
      @listener.send(:read_messages)

      assert_equal messages_yielded.size, 2
      assert messages_yielded.include?(@message1)
      assert messages_yielded.include?(@message2)
    end

    def test_ok_if_message_processor_is_nil
      messages_yielded = []
      @listener = QueueListener.new(aws_client, propono_config, @topic_name)

      @listener.send(:process_message, "")
      assert_equal messages_yielded.size, 0
    end

    def test_each_message_processor_context
      ids = []
      @listener = QueueListener.new(aws_client, propono_config, @topic_name) { |_, context| ids << context[:id] }
      @listener.send(:read_messages)

      assert_equal ids.size, 2
      assert ids.include?(@message1_id)
      assert ids.include?(@message2_id)
    end

    def test_each_message_is_deleted
      queue = "test-queue-url"

      aws_client.expects(:delete_from_sqs).with(queue, @receipt_handle1)
      aws_client.expects(:delete_from_sqs).with(queue, @receipt_handle2)

      @listener.stubs(queue: queue)
      @listener.send(:read_messages_from_queue, queue, propono_config.num_messages_per_poll)
    end

    def test_messages_are_deleted_if_there_is_an_exception_processing
      aws_client.expects(:delete_from_sqs).with(@queue, @receipt_handle1)
      aws_client.expects(:delete_from_sqs).with(@queue, @receipt_handle2)

      exception = StandardError.new("Test Error")
      @listener = QueueListener.new(aws_client, propono_config, @topic_name) { raise exception }
      @listener.stubs(:requeue_message_on_failure).with(SqsMessage.new(@sqs_message1), exception)
      @listener.stubs(:requeue_message_on_failure).with(SqsMessage.new(@sqs_message2), exception)
      @listener.send(:read_messages_from_queue, @queue, propono_config.num_messages_per_poll)
    end

    def test_messages_are_retried_or_abandoned_on_failure
      exception = StandardError.new("Test Error")
      @listener = QueueListener.new(aws_client, propono_config, @topic_name) { raise exception }
      @listener.expects(:requeue_message_on_failure).with(SqsMessage.new(@sqs_message1), exception)
      @listener.expects(:requeue_message_on_failure).with(SqsMessage.new(@sqs_message2), exception)
      @listener.send(:read_messages_from_queue, @queue, propono_config.num_messages_per_poll)
    end

    def test_failed_on_moving_to_failed_queue_does_not_delete
      exception = StandardError.new("Test Error")
      @listener = QueueListener.new(aws_client, propono_config, @topic_name) { raise exception }
      @listener.stubs(:requeue_message_on_failure).with(SqsMessage.new(@sqs_message1), exception).raises(StandardError.new("failed to move"))
      @listener.stubs(:requeue_message_on_failure).with(SqsMessage.new(@sqs_message2), exception).raises(StandardError.new("failed to move"))
      @listener.expects(:delete_message).with(@sqs_message1).never
      @listener.expects(:delete_message).with(@sqs_message2).never
      @listener.send(:read_messages_from_queue, @queue, propono_config.num_messages_per_poll)
    end

    def test_messages_are_moved_to_corrupt_queue_if_there_is_an_parsing_exception
      sqs_message1 = mock(body: "foobar", receipt_handle: "123")
      sqs_message2 = mock(body: "barfoo", receipt_handle: "321")
      @messages[0] = sqs_message1
      @messages[1] = sqs_message2

      @listener.expects(:move_to_corrupt_queue).with(sqs_message1)
      @listener.expects(:move_to_corrupt_queue).with(sqs_message2)
      @listener.send(:read_messages_from_queue, @queue, propono_config.num_messages_per_poll)
    end

    def test_message_moved_to_failed_queue_if_there_is_an_exception_and_retry_count_is_zero
      aws_client.expects(:send_to_sqs).with(@failed_queue, anything)
      @listener.send(:requeue_message_on_failure, SqsMessage.new(@sqs_message1), StandardError.new)
    end

    def test_message_requeued_if_there_is_an_exception_but_failure_count_less_than_retry_count
      propono_config.max_retries = propono_config.num_messages_per_poll
      message = SqsMessage.new(@sqs_message1)
      message.stubs(failure_count: 4)
      aws_client.expects(:send_to_sqs).with(@queue, anything)
      @listener.send(:requeue_message_on_failure, message, StandardError.new)
    end

    def test_message_requeued_if_there_is_an_exception_but_failure_count_exceeds_than_retry_count
      propono_config.max_retries = propono_config.num_messages_per_poll
      message = SqsMessage.new(@sqs_message1)
      message.stubs(failure_count: propono_config.num_messages_per_poll)
      aws_client.expects(:send_to_sqs).with(@failed_queue, anything)
      @listener.send(:requeue_message_on_failure, message, StandardError.new)
    end

    def test_move_to_corrupt_queue
      aws_client.expects(:send_to_sqs).with(@corrupt_queue, @sqs_message1.body)
      @listener.send(:move_to_corrupt_queue, @sqs_message1)
    end

    def test_if_no_messages_read_from_normal_queue_read_from_slow_queue
      main_queue = mock
      @listener.stubs(main_queue: main_queue)
      slow_queue = mock
      @listener.stubs(slow_queue: slow_queue)

      @listener.expects(:read_messages_from_queue).with(main_queue, propono_config.num_messages_per_poll).returns(false)
      @listener.expects(:read_messages_from_queue).with(slow_queue, 1)
      @listener.send(:read_messages)
    end

    def test_if_read_messages_from_normal_do_not_read_from_slow_queue
      main_queue = mock
      @listener.stubs(main_queue: main_queue)

      @listener.expects(:read_messages_from_queue).with(main_queue, propono_config.num_messages_per_poll).returns(true)
      @listener.send(:read_messages)
    end

    def test_idle_timeout_is_nil_by_default
      assert_equal nil, @listener.idle_timeout

      @listener.expects(:last_message_read_at).never

      thread = Thread.new { @listener.listen }
      sleep 1

    ensure
      thread.terminate if thread
    end

    def test_idle_timeout_exits_loop
      timeout = 1

      @listener = QueueListener.new(aws_client, propono_config, @topic_name, idle_timeout: timeout) {}
      @listener.stubs(:read_messages_from_queue).returns(false)

      @time = Time.now.to_i
      @listener.listen

      assert true
      assert Time.now.to_i - @time >= timeout
    end
  end
end
