class Hash
  def symbolize_keys
    inject({}) do |result, (key, value)|
      new_key = key.is_a?(String) ? key.to_sym : key
      new_value = value.is_a?(Hash) ? value.symbolize_keys : value
      result[new_key] = new_value
      result
    end
  end
end
