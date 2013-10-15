require File.expand_path('../test_helper', __FILE__)

module Propono
  class QueueTest < Minitest::Test
    def test_intialization_sets_url
      url = 'foobar'
      queue = Queue.new(url)
      assert url, queue.url
    end

    def test_arn
      skip
    end
  end
end

