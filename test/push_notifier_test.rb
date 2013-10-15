require File.expand_path('../test_helper', __FILE__)

module Propono
  class PushNotifierTest < Minitest::Test

    def test_initialization
      notifier = PushNotifier.new
      refute notifier.nil?
    end

  end
end
