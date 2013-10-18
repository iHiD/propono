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
    Propono::Configuration.instance.access_key = "test-access-key"
    Propono::Configuration.instance.secret_key = "test-secret-key"
    Propono::Configuration.instance.queue_region = "us-east-1"
    Propono::Configuration.instance.application_name = "MyApp"
  end

  def config
    Propono::Configuration.instance
  end

  # capture_io reasigns stderr. Assign the config.logger
  # to where capture_io has redirected it to for this test.
  def capture_io(&block)
    require 'stringio'

    orig_stdout, orig_stderr         = $stdout, $stderr
    captured_stdout, captured_stderr = StringIO.new, StringIO.new
    $stdout, $stderr                 = captured_stdout, captured_stderr

    config.logger = $stderr
    yield

    return captured_stdout.string, captured_stderr.string
  ensure
    $stdout = orig_stdout
    $stderr = orig_stderr
    config.logger = $stderr
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
