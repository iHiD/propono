require 'fog/aws'

module Propono
  module Sns
    private

    def sns
      @sns ||= Fog::AWS::SNS.new(Propono.aws_options)
    end

    def aws_sns
      @aws_sns ||= Aws::SNS::Client.new(Propono.aws_options)
    end
  end
end
