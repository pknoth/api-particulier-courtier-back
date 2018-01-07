require 'rails_helper'

RSpec.describe Field, type: :model do
  it 'can be a section' do
    field = Field::Section.create
    expect(field).to be_persisted
  end

  # TODO: won't work with rails autoloading constant
  # it 'can be a string' do
  #   field = Field::String.create
  #   expect(field).to be_persisted
  # end
  # it 'can be a boolean' do
  #   field = Object.const_get('Field::Boolean').create
  #   expect(field).to be_persisted
  # end

  describe 'I have a boolean' do
    let(:boolean) { FactoryGirl.create(:field, :boolean) }

    it 'have boolean as answer type' do
      expect(boolean.answer_type).to eq('BooleanType')
    end
  end

  describe 'I have a json' do
    let(:boolean) { FactoryGirl.create(:field, :json) }

    it 'have boolean as answer type' do
      expect(boolean.answer_type).to eq('JsonType')
    end
  end

  describe 'I have a string' do
    let(:boolean) { FactoryGirl.create(:field, :string) }

    it 'have boolean as answer type' do
      expect(boolean.answer_type).to eq('StringType')
    end
  end

  describe 'I have a section' do
    let(:section) { FactoryGirl.create(:field, :section) }

    it 'can be a fieldable of an enrollment' do
      enrollment = FactoryGirl.create(:enrollment)

      section.update(fieldable: enrollment)

      expect(section.reload.fieldable).to eq(enrollment)
    end
  end
end
