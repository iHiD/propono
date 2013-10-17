require 'fog'

module Propono
  module Sqs
    private

    def sqs
      @sqs ||= Fog::AWS::SQS.new(
        :aws_access_key_id => config.access_key,
        :aws_secret_access_key => config.secret_key,
        :region => config.queue_region
      )
    end

    def config
      Configuration.instance
    end
  end
end

