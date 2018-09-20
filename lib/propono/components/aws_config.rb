module Propono
  class AwsConfig

    def initialize(config)
      @config = config
    end

    def aws_options
      if @config.use_iam_profile
        {
          :credentials => Aws::InstanceProfileCredentials.new(),
          :region => @config.queue_region
        }
      else
        {
          :access_key_id => @config.access_key,
          :secret_access_key => @config.secret_key,
          :region => @config.queue_region
        }
      end
    end
  end
end
