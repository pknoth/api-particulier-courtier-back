# frozen_string_literal: true

FactoryGirl.define do
  factory :document do
    document_type { FactoryGirl.build(:document_type) }
    attachment { Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf') }
    subscription
  end
end
