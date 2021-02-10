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
    @propono_config ||= Propono::Configuration.new.tap do |c|
      c.application_name = "MyApp"
      c.queue_suffix = ""

      c.logger.stubs(:debug)
      c.logger.stubs(:info)
      c.logger.stubs(:error)
    end
  end

  def aws_client
    @aws_client ||= Propono::AwsClient.new(mock).tap do |c|
      c.stubs(:sns_client)
      c.stubs(:sqs_client)
    end
  end
end
