require File.expand_path('../test_helper', __FILE__)

module Propono
  class ConfigurationTest < Minitest::Test

    def setup
      super
      Propono.instance_variable_set("@config", nil)
    end

    def test_obtaining_singletion
      refute propono_config.nil?
    end

    def test_use_iam_profile_defaults_false
      assert ! propono_config.use_iam_profile
    end

    def test_use_iam_profile
      propono_config.use_iam_profile = true
      assert propono_config.use_iam_profile
    end

    def test_sqs_endpoint_defaults_false
      assert ! propono_config.sqs_endpoint
    end

    def test_sqs_endpoint
      propono_config.sqs_endpoint = true
      assert propono_config.sqs_endpoint
    end

    def test_sns_endpoint_defaults_false
      assert ! propono_config.sns_endpoint
    end

    def test_sns_endpoint
      propono_config.sns_endpoint = true
      assert propono_config.sns_endpoint
    end

    def test_access_key
      access_key = "test-access-key"
      propono_config.access_key = access_key
      assert_equal access_key, propono_config.access_key
    end

    def test_secret_key
      secret_key = "test-secret-key"
      propono_config.secret_key = secret_key
      assert_equal secret_key, propono_config.secret_key
    end

    def test_queue_region
      queue_region = "test-queue-region"
      propono_config.queue_region = queue_region
      assert_equal queue_region, propono_config.queue_region
    end

    def test_application_name
      application_name = "test-application-name"
      propono_config.application_name = application_name
      assert_equal application_name, propono_config.application_name
    end

    def test_default_logger
      assert propono_config.logger.is_a?(Propono::Logger)
    end

    def test_logger
      propono_config.logger = :my_logger
      assert_equal :my_logger, propono_config.logger
    end

    def test_default_queue_suffix
      assert_equal "", propono_config.queue_suffix
    end

    def test_queue_suffix
      queue_suffix = "test-application-name"
      propono_config.queue_suffix = queue_suffix
      assert_equal queue_suffix, propono_config.queue_suffix
    end

    def test_default_num_messages_per_poll
      assert_equal 10, propono_config.num_messages_per_poll
    end

    def test_num_messages_per_poll
      val = 3
      propono_config.num_messages_per_poll = val
      assert_equal val, propono_config.num_messages_per_poll
    end

    def test_missing_access_key_throws_exception
      assert_raises(ProponoConfigurationError) do
        propono_config.access_key
      end
    end

    def test_missing_secret_key_throws_exception
      assert_raises(ProponoConfigurationError) do
        propono_config.secret_key
      end
    end

    def test_missing_queue_region_throws_exception
      assert_raises(ProponoConfigurationError) do
        propono_config.queue_region
      end
    end

    def test_missing_application_name_throws_exception
      assert_raises(ProponoConfigurationError) do
        propono_config.application_name
      end
    end

    def test_missing_logger_throws_exception
      propono_config.logger = nil
      assert_raises(ProponoConfigurationError) do
        propono_config.logger
      end
    end

    def test_missing_max_retries_throws_exception
      propono_config.max_retries = nil
      assert_raises(ProponoConfigurationError) do
        propono_config.max_retries
      end
    end

    def test_missing_num_messages_per_poll_throws_exception
      propono_config.num_messages_per_poll = nil
      assert_raises(ProponoConfigurationError) do
        propono_config.num_messages_per_poll
      end
    end

    def test_default_max_retries
      assert_equal 0, propono_config.max_retries
    end

    def test_max_retries
      val = 5
      propono_config.max_retries = val
      assert_equal 5, propono_config.max_retries
    end

    def propono_config
      @propono_config ||= Propono::Configuration.new
    end
  end
end

