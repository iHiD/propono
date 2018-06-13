module Propono
  class AwsConfig

    def initialize(config)
      @config = config
    end

    def aws_options
      if @config.use_iam_profile
        options = {
          :region => @config.queue_region,
          :retries => @config.iam_profile_credentials_retries || 5,
          :http_open_timeout => @config.iam_profile_credentials_timeout || 5,
          :http_read_timeout => @config.iam_profile_credentials_timeout || 5
        }

        { :credentials => Aws::InstanceProfileCredentials.new(options) }
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
