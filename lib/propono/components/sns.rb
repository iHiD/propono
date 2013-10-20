require 'fog'

module Propono
  module Sns
    private

    def sns
      @sns ||= Fog::AWS::SNS.new(
        :aws_access_key_id => Propono.config.access_key,
        :aws_secret_access_key => Propono.config.secret_key,
        :region => Propono.config.queue_region
      )
    end
  end
end
