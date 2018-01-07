class JsonType
  def self.new(json)
    return json if json.is_a?(Hash)
    return JSON.parse(json) if json.is_a?(String)
  end
end
