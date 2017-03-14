require File.expand_path('../../test_helper', __FILE__)

module Propono
  class QueueTest < Minitest::Test
    def test_url
      url = 'foobar'
      queue = Queue.new(url, nil)
      assert url, queue.url
    end

    def test_arn
      arn = 'foobar'
      attributes = {"QueueArn" => arn}
      queue = Queue.new(nil, attributes)
      assert arn, queue.arn
    end
  end
end

