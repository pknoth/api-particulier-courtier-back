# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Enrollment, type: :model do
  let(:enrollment) { FactoryGirl.create(:enrollment) }

  it 'can have subscriptions' do
    enrollment.subscriptions << FactoryGirl.build(:subscription)
    expect(enrollment.subscriptions).not_to be_empty
  end

  it 'can have scopes' do
    enrollment.scopes << FactoryGirl.build(:scope)
    expect(enrollment.scopes).not_to be_empty
  end

  describe 'I have deep fields attached to it' do
    let(:enrollment) {
      FactoryGirl.create(:enrollment, fields: [
        FactoryGirl.build(:field, :section, fields: [
          FactoryGirl.build(:field, :boolean)
        ])
      ])
    }
    it 'has all_fields method that return all fields (even nested ones)' do
      expect(enrollment.all_fields.count).to eq(2)
    end
  end
end
