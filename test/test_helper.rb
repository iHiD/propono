gem "minitest"
require "minitest/autorun"
require "minitest/pride"
require "minitest/mock"
require "mocha/setup"

lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "propono"

Fog.mock!

class Minitest::Test
  def setup
    Propono::Configuration.instance.access_key = "test-access-key"
    Propono::Configuration.instance.secret_key = "test-secret-key"
    Propono::Configuration.instance.queue_region = "us-east-1"
  end
end

class Fog::AWS::SNS::Mock
  def create_topic(*args)
    foo = Object.new
    class << foo
      def body
        {"TopicArn" => "FoobarFromTheMock"}
      end
    end
    foo
  end

  def subscribe(arn, url, type)

  end
end

class Fog::AWS::SQS::Mock
  def create_queue(*args)

  end
end
