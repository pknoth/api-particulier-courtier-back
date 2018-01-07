require 'rails_helper'

RSpec.describe EnrollmentsController, type: :controller do
  describe '#index' do
    before do
      FactoryGirl.create_list(:enrollment, 5)
    end

    it 'is a success' do
      get :index

      expect(response).to be_success
    end

    it 'respond with 5 enrollments' do
      get :index

      json = JSON.parse(response.body)
      expect(json.count).to eq(5)
    end
  end

  describe '#show' do
    let(:enrollment) { FactoryGirl.create(:enrollment) }

    it 'is a success' do
      get :show, params: { id: enrollment.id }

      expect(response).to be_success
    end
  end
end
