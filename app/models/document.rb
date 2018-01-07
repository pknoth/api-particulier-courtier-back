# frozen_string_literal: true

class Document < ApplicationRecord
  attr_accessor :attachment_type
  mount_uploader :attachment, DocumentUploader

  belongs_to :subscription
  belongs_to :document_type, optional: true
  delegate :name, to: :document_type

  validates_presence_of :attachment

  before_save :overwrite
  after_save :touch_subscription
  after_save :attach_document_type

  default_scope -> { where(archive: false) }

  private

  def touch_subscription
    subscription.touch
  end

  def overwrite
    subscription
      .documents
      .where(document_type: document_type)
      .update_all(archive: true)
  end

  def attach_document_type
    document_type = subscription.enrollment.document_types.find_by(name: attachment_type)
    update_attribute(:document_type_id, document_type&.id)
  end
end
