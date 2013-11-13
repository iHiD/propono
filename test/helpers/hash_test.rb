require File.expand_path('../../test_helper', __FILE__)

module Propono
  class HashTest < Minitest::Test
    def test_symbolize_keys_works
      input = {
        "foo" => "bar",
        cat: 1,
        "nest" => {
          "dog" => [
            {"mouse" => true}
          ]
        }
      }
      expected = {
        foo: 'bar',
        cat: 1,
        nest: {
          dog: [
            {"mouse" => true}
          ]
        }
      }

      assert_equal expected, input.symbolize_keys
    end
  end
end


