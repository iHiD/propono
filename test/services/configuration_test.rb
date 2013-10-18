require File.expand_path('../../test_helper', __FILE__)

module Propono
  class ConfigurationTest < Minitest::Test
    def config
      @config ||= Configuration.send(:new)
    end

    def test_obtaining_singletion
      refute config.nil?
    end

    def test_unable_to_create_instance
      assert_raises(NoMethodError) do
        config = Configuration.new
      end
    end

    def test_access_key
      access_key = "test-access-key"
      config.access_key = access_key
      assert_equal access_key, config.access_key
    end

    def test_secret_key
      secret_key = "test-secret-key"
      config.secret_key = secret_key
      assert_equal secret_key, config.secret_key
    end

    def test_queue_region
      queue_region = "test-queue-region"
      config.queue_region = queue_region
      assert_equal queue_region, config.queue_region
    end

    def test_application_name
      application_name = "test-application-name"
      config.application_name = application_name
      assert_equal application_name, config.application_name
    end

    def test_missing_access_key_throws_exception
      assert_raises(ConfigurationError) do
        config.access_key
      end
    end

    def test_missing_secret_key_throws_exception
      assert_raises(ConfigurationError) do
        config.secret_key
      end
    end

    def test_missing_queue_region_throws_exception
      assert_raises(ConfigurationError) do
        config.queue_region
      end
    end

    def test_missing_application_name_throws_exception
      assert_raises(ConfigurationError) do
        config.application_name
      end
    end
  end
end

