require File.expand_path('../test_helper', __FILE__)

module Propono
  class ProponoTest < Minitest::Test

    def setup
      super
      @var1 = "Foobar"
      @var2 = 123
    end

    def test_publish_calls_publisher_public
      Publisher.expects(:publish).with(@var1, @var2)
      Propono.publish(@var1, @var2)
    end
  end
end
