module Propono
  class Queue

    include Sqs

    attr_reader :url
    def initialize(url)
      @url = url
    end

    def arn
      attributes = sqs.get_queue_attributes(@url, 'QueueArn').body["Attributes"]
      attributes["QueueArn"]
    end
  end
end
