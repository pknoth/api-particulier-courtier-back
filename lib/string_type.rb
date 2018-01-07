class StringType < String
  def self.new(str)
    String.new(str) if str
  end
end
