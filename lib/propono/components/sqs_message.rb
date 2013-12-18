module Propono
  class SqsMessage
    include Sqs

    attr_reader :context, :message, :raw_message, :receipt_handle, :failure_count
    def initialize(raw_message)
      raw_body = raw_message["Body"]
      @raw_body_json = JSON.parse(raw_body)
      body = JSON.parse(@raw_body_json["Message"])

      @raw_message    = raw_message
      @context        = body.symbolize_keys
      @failure_count  = context[:num_failures] || 0
      @message        = context.delete(:message)
      @receipt_handle = raw_message["receipt_handle"]
    end

    def to_json_with_exception(exception)
      message = @raw_body_json.dup
      context = {}
      context[:id] = @context[:id]
      context[:message] = @message
      context[:last_exception_message] = exception.message
      context[:last_exception_stack_trace] = exception.backtrace
      context[:last_exception_time] = Time.now
      context[:num_failures] = failure_count + 1
      context[:last_context] = @context
      message['Message'] = context.to_json
      JSON.pretty_generate(message)
    end

    def ==(other)
      other.is_a?(SqsMessage) && other.receipt_handle == @receipt_handle
    end
  end
end
