class Answer < ApplicationRecord
  serialize :content

  belongs_to :field
  belongs_to :subscription

  before_save :serialize_content
  before_save :overwrite

  private

  def serialize_content
    self.content = Object.const_get(field.answer_type).new(content)
  end

  def overwrite
    subscription
      .answers
      .where(field: field)
      .delete_all
  end
end
