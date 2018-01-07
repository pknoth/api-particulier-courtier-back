# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  describe 'with fc user' do
    let(:uid) { 1 }
    let(:user) { FactoryGirl.create(:user, uid: uid, provider: 'france_connect') }
    let(:subscription) { FactoryGirl.create(:subscription) }
    before do
      user.add_role(:applicant, subscription)
      @request.headers['Authorization'] = 'Bearer test'
      stub_request(:get, 'http://test.host/api/v1/me')
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer test',
            'User-Agent' => 'Faraday v0.12.1'
          }
        ).to_return(status: 200, body: "{\"id\": #{uid}}", headers: { 'Content-Type' => 'application/json' })
    end

    let(:message) { FactoryGirl.create(:message, subscription: subscription) }
    let(:valid_attributes) do
      { subscription_id: subscription.id, content: 'test' }
    end

    let(:invalid_attributes) do
      { subscription_id: subscription.id, content: '' }
    end

    describe 'GET #index' do
      it 'returns a success response' do
        get :index, params: { message: { subscription_id: subscription.id } }
        expect(response).to be_success
      end
    end

    describe 'GET #show' do
      describe 'the user owns the message' do
        it 'returns a success response' do
          get :show, params: { id: message.to_param, message: { subscription_id: subscription.id } }

          expect(response).to be_success
        end
      end

      describe 'the user do not own the message' do
        let(:message) { FactoryGirl.create(:message) }
        it 'returns an error' do
          get :show, params: { id: message.to_param, message: { subscription_id: subscription.id } }
          expect(response).not_to be_success
        end
      end
    end

    describe 'POST #create' do
      context 'with valid params' do
        it 'creates a new Message' do
          expect do
            post :create, params: { message: valid_attributes }
          end.to change(Message, :count).by(1)
        end

        it 'is a success' do
          post :create, params: { message: valid_attributes }
          expect(response).to be_success
        end

        it 'current user own the message' do
          post :create, params: { message: valid_attributes }
          expect(Message.last.sender).to eq(user)
        end

        it 'the message is linked to subscription' do
          post :create, params: { message: valid_attributes }
          expect(Message.last.subscription).to eq(subscription)
        end
      end

      context 'with invalid params' do
        it "returns a failure" do
          post :create, params: { message: invalid_attributes }
          expect(response).not_to be_success
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the requested message' do
        message
        expect do
          delete :destroy, params: { id: message.to_param, message: { subscription_id: subscription.id } }
        end.to change(Message, :count).by(-1)
      end

      it 'is a success' do
        delete :destroy, params: { id: message.to_param, message: { subscription_id: subscription.id } }
        expect(response).to be_success
      end
    end
  end

  describe 'with dgfip user' do
    let(:uid) { 1 }
    let(:user) { FactoryGirl.create(:user, uid: uid, provider: 'dgfip') }
    let(:subscription) { FactoryGirl.create(:subscription) }
    before do
      user.add_role(:applicant, subscription)
      @request.headers['Authorization'] = 'Bearer test'
      stub_request(:get, 'http://test.host/api/v1/me')
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer test',
            'User-Agent' => 'Faraday v0.12.1'
          }
          ).to_return(status: 200, body: "{\"id\": #{uid},\"scopes\":[\"dgfip\"]}", headers: { 'Content-Type' => 'application/json' })
    end

    let(:message) { FactoryGirl.create(:message, subscription: subscription) }
    let(:valid_attributes) do
      { subscription_id: subscription.id, content: 'test' }
    end

    let(:invalid_attributes) do
      { subscription_id: subscription.id, content: '' }
    end

    describe 'GET #index' do
      it 'returns a success response' do
        get :index, params: { subscription_id: subscription.id }
        expect(response).to be_success
      end
    end

    describe 'GET #show' do
      describe 'the user owns the message' do
        it 'returns a success response' do
          get :show, params: { id: message.to_param, subscription_id: subscription.id }
          expect(response).to be_success
        end
      end

      describe 'the user do not own the message' do
        let(:message) { FactoryGirl.create(:message, subscription: subscription) }
        it 'returns an error' do
          get :show, params: { id: message.to_param, subscription_id: subscription.id }
          expect(response).to be_success
        end
      end
    end

    describe 'POST #create' do
      context 'with valid params' do
        it 'creates a new Message' do
          expect do
            post :create, params: { message: valid_attributes }
          end.to change(Message, :count).by(1)
        end

        it 'is a success' do
          post :create, params: { message: valid_attributes }
          expect(response).to be_success
        end

        it 'current user own the message' do
          post :create, params: { message: valid_attributes }
          expect(Message.last.sender).to eq(user)
        end

        it 'the message is linked to subscription' do
          post :create, params: { message: valid_attributes }
          expect(Message.last.subscription).to eq(subscription)
        end
      end

      context 'with invalid params' do
        it "returns a success response (i.e. to display the 'new' template)" do
          post :create, params: { message: invalid_attributes, subscription_id: subscription.id }
          expect(response).not_to be_success
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the requested message' do
        message
        expect do
          delete :destroy, params: { id: message.to_param, subscription_id: subscription.id }
        end.to change(Message, :count).by(-1)
      end

      it 'is a success' do
        delete :destroy, params: { id: message.to_param, subscription_id: subscription.id }
        expect(response).to be_success
      end
    end
  end
end
