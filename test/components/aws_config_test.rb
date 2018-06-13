require File.expand_path('../../test_helper', __FILE__)

module Propono
  class AwsConfigTest < Minitest::Test

    def setup
      super
      @config = Propono::Configuration.new

      @config.access_key = "test-access-key"
      @config.secret_key = "test-secret-key"
      @config.queue_region = "test-queue-region"

      @aws_config = Propono::AwsConfig.new(@config)
    end

    def test_access_key
      assert_equal "test-access-key", @aws_config.aws_options[:access_key_id]
    end

    def test_secret_key
      assert_equal "test-secret-key", @aws_config.aws_options[:secret_access_key]
    end

    def test_region
      assert_equal "test-queue-region", @aws_config.aws_options[:region]
    end

    def test_no_iam_profile_selected
      assert ! @aws_config.aws_options.has_key?(:use_iam_profile)
    end

    def test_using_iam_profile_results_in_aws_instance_profile_credentials_default
      @config.use_iam_profile = true
      aws_credentials = @aws_config.aws_options[:credentials]

      assert_equal 5, aws_credentials.instance_variable_get("@retries")
      assert_equal 5, aws_credentials.instance_variable_get("@http_open_timeout")
      assert_equal 5, aws_credentials.instance_variable_get("@http_read_timeout")
    end

    def test_using_iam_profile_results_in_aws_instance_profile_credentials
      @config.use_iam_profile = true
      @config.iam_profile_credentials_retries = 3
      @config.iam_profile_credentials_timeout = 4
      aws_credentials = @aws_config.aws_options[:credentials]

      assert_equal 3, aws_credentials.instance_variable_get("@retries")
      assert_equal 4, aws_credentials.instance_variable_get("@http_open_timeout")
      assert_equal 4, aws_credentials.instance_variable_get("@http_read_timeout")
    end
  end
end
