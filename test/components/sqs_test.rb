require File.expand_path('../../test_helper', __FILE__)

module Propono
  class SqsTest < Minitest::Test
    class SqsTestClass
      include Sqs
    end

    def setup
      super
      Propono.config.access_key = "test-access-key"
      Propono.config.secret_key = "test-secret-key"
      Propono.config.queue_region = "us-east-1"
    end

    def test_sqs
      Fog::AWS::SQS.expects(:new)
        .with(:aws_access_key_id     => 'test-access-key',
              :aws_secret_access_key => 'test-secret-key',
              :region                => 'us-east-1')

      SqsTestClass.new.send :sqs
    end
  end
end

