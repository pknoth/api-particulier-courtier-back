# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Document, type: :model do
  it 'can be linked to a document_type' do
    document = FactoryGirl.create(:document, attachment_type: 'Document::CNILVoucher')

    expect(Document.find(document.id).document_type.name).to eq('Document::CNILVoucher')
  end
end
