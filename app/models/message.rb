# frozen_string_literal: true

class Message < ApplicationRecord
  validates_presence_of :content

  belongs_to :subscription, optional: true
  resourcify

  def sender
    User.with_role(:sender, self).first
  end

  def reciepients
    enrollment.user
  end
end
