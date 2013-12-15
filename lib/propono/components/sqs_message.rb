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

    def ==(other)
      other.is_a?(SqsMessage) && other.receipt_handle == @receipt_handle
    end
  end
end
