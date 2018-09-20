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

    def test_sns_options_access_key
      assert_equal "test-access-key", @aws_config.sns_options[:access_key_id]
    end

    def test_sns_options_secret_key
      assert_equal "test-secret-key", @aws_config.sns_options[:secret_access_key]
    end

    def test_sns_options_region
      assert_equal "test-queue-region", @aws_config.sns_options[:region]
    end

    def test_sns_options_no_iam_profile_selected
      assert ! @aws_config.sns_options.has_key?(:use_iam_profile)
    end

    def test_sns_options_use_iam_profile
      @config.use_iam_profile = true
      assert @aws_config.sns_options[:use_iam_profile]
    end

    def test_sns_options_selecting_use_iam_profile_results_in_no_access_key
      @config.use_iam_profile = true
      assert ! @aws_config.sns_options.has_key?(:access_key_id)
    end

    def test_sns_options_selecting_use_iam_profile_results_in_no_secret_key
      @config.use_iam_profile = true
      assert ! @aws_config.sns_options.has_key?(:secret_access_key)
    end

    def test_sns_options_region_when_using_iam_profile
      @config.use_iam_profile = true
      assert_equal "test-queue-region", @aws_config.sns_options[:region]
    end

    def test_sns_options_endpoint_when_no_endpoint_specified
      assert_nil   @aws_config.sns_options[:endpoint]
      assert_equal "test-queue-region", @aws_config.sns_options[:region]
    end

    def test_sns_options_endpoint_when_endpoint_specified
      @config.sns_endpoint = "http://my.endpoint:3333"

      assert_equal "http://my.endpoint:3333", @aws_config.sns_options[:endpoint]
      assert_nil   @aws_config.sns_options[:region]
    end

    def test_sqs_options_access_key
      assert_equal "test-access-key", @aws_config.sqs_options[:access_key_id]
    end

    def test_sqs_options_secret_key
      assert_equal "test-secret-key", @aws_config.sqs_options[:secret_access_key]
    end

    def test_sqs_options_region
      assert_equal "test-queue-region", @aws_config.sqs_options[:region]
    end

    def test_sqs_options_no_iam_profile_selected
      assert ! @aws_config.sqs_options.has_key?(:use_iam_profile)
    end

    def test_sqs_options_use_iam_profile
      @config.use_iam_profile = true
      assert @aws_config.sqs_options[:use_iam_profile]
    end

    def test_sqs_options_selecting_use_iam_profile_results_in_no_access_key
      @config.use_iam_profile = true
      assert ! @aws_config.sqs_options.has_key?(:access_key_id)
    end

    def test_sqs_options_selecting_use_iam_profile_results_in_no_secret_key
      @config.use_iam_profile = true
      assert ! @aws_config.sqs_options.has_key?(:secret_access_key)
    end

    def test_sqs_options_region_when_using_iam_profile
      @config.use_iam_profile = true
      assert_equal "test-queue-region", @aws_config.sqs_options[:region]
    end

    def test_sqs_options_endpoint_when_no_endpoint_specified
      assert_nil   @aws_config.sqs_options[:endpoint]
      assert_equal "test-queue-region", @aws_config.sqs_options[:region]
    end

    def test_sqs_options_endpoint_when_endpoint_specified
      @config.sqs_endpoint = "http://my.endpoint:3333"

      assert_equal "http://my.endpoint:3333", @aws_config.sqs_options[:endpoint]
      assert_nil   @aws_config.sqs_options[:region]
    end

  end
end
