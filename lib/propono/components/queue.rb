module Propono
  class Queue

    attr_reader :url, :attributes
    def initialize(url, attributes)
      @url = url
      @attributes = attributes
    end

    def arn
      @arn ||= attributes["QueueArn"]
    end
  end
end
