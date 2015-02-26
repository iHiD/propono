require File.expand_path('../../test_helper', __FILE__)

module Propono
  class SnsTest < Minitest::Test
    class SnsTestClass
      include Sns
    end

    def setup
      super
      Propono.config.access_key = "test-access-key"
      Propono.config.secret_key = "test-secret-key"
      Propono.config.queue_region = "test-queue-region"
    end

    def test_sns
      Fog::AWS::SNS.expects(:new)
        .with(:aws_access_key_id     => 'test-access-key',
              :aws_secret_access_key => 'test-secret-key',
              :region                => 'test-queue-region')

      SnsTestClass.new.send :sns
    end
  end
end
