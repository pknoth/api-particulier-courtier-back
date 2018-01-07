class BooleanType
  THE_TRUTH = [true, 'True', 'true', '1', 1].freeze

  def self.new(bool)
    return true if THE_TRUTH.include?(bool)
    false
  end
end
