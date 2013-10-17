module Propono
  class Topic

    include Sqs

    attr_reader :arn
    def initialize(arn)
      @arn = arn
    end
  end
end
