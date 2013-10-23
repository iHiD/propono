require File.expand_path('../test_helper', __FILE__)

module Propono
  class ConfigurationTest < Minitest::Test

    def setup
      Propono.instance_variable_set("@config", nil)
    end

    def test_obtaining_singletion
      refute Propono.config.nil?
    end

    def test_block_syntax
      test_key = "foobar-123-access"
      Propono.config do |config|
        config.access_key = test_key
      end
      assert_equal test_key, Propono.config.access_key
    end

    def test_access_key
      access_key = "test-access-key"
      Propono.config.access_key = access_key
      assert_equal access_key, Propono.config.access_key
    end

    def test_secret_key
      secret_key = "test-secret-key"
      Propono.config.secret_key = secret_key
      assert_equal secret_key, Propono.config.secret_key
    end

    def test_queue_region
      queue_region = "test-queue-region"
      Propono.config.queue_region = queue_region
      assert_equal queue_region, Propono.config.queue_region
    end

    def test_application_name
      application_name = "test-application-name"
      Propono.config.application_name = application_name
      assert_equal application_name, Propono.config.application_name
    end

    def test_udp_host
      val = "test-application-name"
      Propono.config.udp_host = val
      assert_equal val, Propono.config.udp_host
    end

    def test_udp_port
      val = 10000
      Propono.config.udp_port = val
      assert_equal val, Propono.config.udp_port
    end

    def test_tcp_host
      val = "test-application-name"
      Propono.config.tcp_host = val
      assert_equal val, Propono.config.tcp_host
    end

    def test_tcp_port
      val = 9382
      Propono.config.tcp_port = val
      assert_equal val, Propono.config.tcp_port
    end

    def test_missing_access_key_throws_exception
      assert_raises(ProponoConfigurationError) do
        Propono.config.access_key
      end
    end

    def test_missing_secret_key_throws_exception
      assert_raises(ProponoConfigurationError) do
        Propono.config.secret_key
      end
    end

    def test_missing_queue_region_throws_exception
      assert_raises(ProponoConfigurationError) do
        Propono.config.queue_region
      end
    end

    def test_missing_application_name_throws_exception
      assert_raises(ProponoConfigurationError) do
        Propono.config.application_name
      end
    end
  end
end

