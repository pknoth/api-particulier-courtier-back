class Field < ApplicationRecord
  belongs_to :fieldable, polymorphic: true, optional: true
  has_many :fields, as: :fieldable
  has_many :answers

  def answer_type
    "#{type.split('::').last}Type"
  end
end
