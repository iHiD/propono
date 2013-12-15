require 'fog'

module Propono
  module Sns
    private

    def sns
      @sns ||= Fog::AWS::SNS.new(Propono.aws_options)
    end
  end
end
