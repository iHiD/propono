require File.expand_path('../../test_helper', __FILE__)

module Propono
  class AwsConfigTest < Minitest::Test

    def setup
      super
      @config = Propono::Configuration.new

      @config.aws_options = { a: 'any', b: 'aws-specific' }
      @config.sqs_options = { a: 'sqs', c: 'sqs-specific' }
      @config.sns_options = { a: 'sns', c: 'sns-specific' }

      @aws_config = Propono::AwsConfig.new(@config)
    end

    def test_overwritten_keys_take_precendence
      assert_equal 'sqs', @aws_config.sqs_options[:a]
      assert_equal 'sns', @aws_config.sns_options[:a]
    end

    def test_common_keys_remain
      assert_equal 'aws-specific', @aws_config.sqs_options[:b]
      assert_equal 'aws-specific', @aws_config.sns_options[:b]
    end

    def test_specific_keys_remain
      assert_equal 'sqs-specific', @aws_config.sqs_options[:c]
      assert_equal 'sns-specific', @aws_config.sns_options[:c]
    end

  end
end
