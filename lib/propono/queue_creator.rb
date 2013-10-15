module Propono
  class QueueCreatorError < Exception
  end

  class QueueCreator
    include Sqs

    def self.find_or_create(name)
      new(name).find_or_create
    end

    def initialize(name)
      @name = name
    end

    def find_or_create
      result = sqs.create_queue(@name)
      body = result.body
      body.fetch('QueueUrl') { raise QueueCreatorError.new("No QueueUrl returned from SQS") }
    end
  end
end
