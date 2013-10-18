require File.expand_path('../../test_helper', __FILE__)

module Propono
  class SqsTest < Minitest::Test
    class SqsTestClass
      include Sqs
    end

    def setup
      config.access_key = "test-access-key"
      config.secret_key = "test-secret-key"
      config.queue_region = "us-east-1"
    end

    def test_sqs
      Fog::AWS::SQS.expects(:new)
        .with(:aws_access_key_id     => 'test-access-key',
              :aws_secret_access_key => 'test-secret-key',
              :region                => 'us-east-1')

      SqsTestClass.new.send :sqs
    end

    private

    def config
      Configuration.instance
    end
  end
end

