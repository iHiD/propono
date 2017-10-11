require File.expand_path('../../test_helper', __FILE__)

module Propono
  class AwsClientTest < Minitest::Test

    def test_publish_to_sns_proxies
      client = AwsClient.new(nil)
      sns_client = mock
      message = {foo: 'bar'}
      topic_arn = "asd"
      topic = mock(arn: topic_arn)
      sns_client.expects(:publish).with(
        topic_arn: topic_arn,
        message: message.to_json
      )
      client.stubs(sns_client: sns_client)
      client.publish_to_sns(topic, message)
    end
  end
end
