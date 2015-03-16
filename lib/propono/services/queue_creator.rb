module Propono
  class QueueCreatorError < ProponoError
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
      urls = sqs.list_queues("QueueNamePrefix" => @name).body["QueueUrls"]
      url = urls.select{|x|x =~ /#{@name}$/}.first

      unless url
        result = sqs.create_queue(@name)
        body = result.body
        url = body.fetch('QueueUrl') { raise QueueCreatorError.new("No QueueUrl returned from SQS") }
      end

      Queue.new(url)
    end
  end
end
