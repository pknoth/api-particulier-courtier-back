require 'rails_helper'

RSpec.describe Answer, type: :model do
  describe 'I have a boolean field' do
    let(:boolean) { FactoryGirl.create(:field, :boolean) }
    let(:answer) { FactoryGirl.create(:answer, field: boolean) }

    it 'serializes the content' do
      answer.update(content: 'true')

      expect(answer.content).to be_a(TrueClass)
    end
  end
end
