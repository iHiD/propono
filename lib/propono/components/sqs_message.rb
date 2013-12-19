module Propono
  class SqsMessage
    include Sqs

    attr_reader :context, :message, :raw_message, :receipt_handle
    def initialize(raw_message)
      body = JSON.parse(raw_message["Body"])["Message"]
      body = JSON.parse(body)

      @raw_message    = raw_message
      @context        = body.symbolize_keys
      @message        = context.delete(:message)
      @receipt_handle = raw_message["receipt_handle"]
    end

    def to_json_with_exception(exception)
      context = @context.dup
      context[:last_exception_message] = exception.message
      context[:last_exception_stack_trace] = exception.backtrace
      context[:num_failures] ||= 0
      context[:num_failures] += 1
      {"Message" => 
        {
          "id" => context[:id],
          "message" => {message: @message, context: context}
        }
      }.to_json
    end

    def ==(other)
      other.is_a?(SqsMessage) && other.receipt_handle == @receipt_handle
    end
  end
end
