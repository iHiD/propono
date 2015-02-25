module Propono
  module Utils

    # Returns +hash+ with all primary and nested keys to string values symbolised
    # To avoid conflicts with ActiveSupport and other libraries that provide Hash symbolisation,
    # this method is kept within the Propono namespace and not mixed into Hash
    def self.symbolize_keys(hash)
      hash.inject({}) do |result, (key, value)|
        new_key = key.is_a?(String) ? key.to_sym : key
        new_value = value.is_a?(Hash) ? symbolize_keys(value) : value
        result[new_key] = new_value
        result
      end
    end

  end
end
