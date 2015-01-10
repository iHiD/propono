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

      assert_equal expected, Propono::Utils.symbolize_keys(input)
    end
  end
end


