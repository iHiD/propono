module Propono
  class AwsConfig

    def initialize(config)
      @config = config
    end

    def sns_options
      options_with_endpoint_or_region(@config.sns_endpoint)
    end

    def sqs_options
      options_with_endpoint_or_region(@config.sqs_endpoint)
    end

    private

    def base_options
      if @config.use_iam_profile
        {
          use_iam_profile: true
        }
      else
        {
          access_key_id:     @config.access_key,
          secret_access_key: @config.secret_key
        }
      end
    end

    def options_with_endpoint_or_region(endpoint)
      if endpoint
        base_options.merge({ endpoint: endpoint })
      else
        base_options.merge({ region: @config.queue_region })
      end
    end
  end
end
