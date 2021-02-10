module Propono
  class AwsConfig

    def initialize(config)
      @config = config
    end

    def sqs_options
      @config.aws_options.merge(@config.sqs_options)
    end

    def sns_options
      @config.aws_options.merge(@config.sns_options)
    end

  end
end
