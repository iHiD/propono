require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

gem "minitest"
require "minitest/autorun"
require "minitest/pride"
require "minitest/mock"
require "mocha/setup"

lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "propono"

class Minitest::Test
  def setup
  end

  def propono_config
    return @propono_config if @propono_config

    @propono_config = Propono::Configuration.new
    @propono_config.access_key = "test-access-key"
    @propono_config.secret_key = "test-secret-key"
    @propono_config.queue_region = "us-east-1"
    @propono_config.application_name = "MyApp"
    @propono_config.queue_suffix = ""

    @propono_config.logger.stubs(:debug)
    @propono_config.logger.stubs(:info)
    @propono_config.logger.stubs(:error)

    @propono_config
  end

  def aws_client
    return @aws_client if @aws_client

    @aws_client = Propono::AwsClient.new(mock)
    @aws_client.stubs(:sns_client)
    @aws_client.stubs(:sqs_client)
    @aws_client
  end
end
