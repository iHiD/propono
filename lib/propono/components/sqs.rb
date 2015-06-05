require 'fog/aws'

module Propono
  module Sqs
    private

    def sqs
      @sqs ||= Fog::AWS::SQS.new(Propono.aws_options)
    end
  end
end

