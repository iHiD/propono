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
    Fog.mock!
    Propono.config do |config|
      config.access_key = "test-access-key"
      config.secret_key = "test-secret-key"
      config.queue_region = "us-east-1"
      config.application_name = "MyApp"
      config.queue_suffix = ""

      config.logger.stubs(:debug)
      config.logger.stubs(:info)
      config.logger.stubs(:error)
    end
  end
end

require 'fog'
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

  def subscribe(topic_arn, arn_or_url, type)
  end
end

class Fog::AWS::SQS::Mock
  def create_queue(*args)
  end
  def set_queue_attributes(*args)
  end
end

Fog::AWS::SQS::Mock::QueueUrl = 'https://meducation.net/foobar'
Fog::AWS::SQS::Mock::QueueArn = 'FoobarArn'
data = {'Attributes' => {"QueueArn" => Fog::AWS::SQS::Mock::QueueArn}}
queues = Fog::AWS::SQS::Mock.data["us-east-1"]["test-access-key"][:queues]
queues[Fog::AWS::SQS::Mock::QueueUrl] = data
