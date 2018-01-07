# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubscriptionsController, type: :controller do
  let(:uid) { 1 }
  let(:user) { FactoryGirl.create(:user, uid: uid) }
  before do
    user
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

  let(:agreement) { FactoryGirl.create(:field, :agreement, required: true) }
  let(:enrollment) { FactoryGirl.create(:enrollment, fields: [agreement]) }
  let(:subscription) { FactoryGirl.create(:subscription, enrollment: enrollment) }

  let(:valid_attributes) do
    { agreement: true }
  end

  let(:invalid_attributes) do
    {}
  end

  describe 'authentication' do
    it 'redirect to users/access_denied if oauth request fails' do
      stub_request(:get, 'http://test.host/api/v1/me')
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer test',
            'User-Agent' => 'Faraday v0.12.1'
          }
        ).to_return(status: 401, body: '', headers: {})

      get :index, params: { enrollment_id: enrollment.name, }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index, params: { enrollment_id: enrollment.name, }

      expect(response).to be_success
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { enrollment_id: enrollment.name, id: subscription.to_param }

      expect(response).to have_http_status(:not_found)
    end

    describe 'with a france_connect user' do
      let(:uid) { 1 }
      let(:user) { FactoryGirl.create(:user, provider: 'france_connect', uid: uid) }

      before do
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

      describe 'user is applicant of subscription' do
        before do
          user.add_role(:applicant, subscription)
        end

        it 'returns a success response' do
          get :show, params: { enrollment_id: enrollment.name, id: subscription.to_param }

          expect(response).to be_success
        end
      end

      describe 'user is not applicant of subscription' do
        it 'returns a success response' do
          get :show, params: { enrollment_id: enrollment.name, id: subscription.to_param }

          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe 'GET #convention' do
    it 'returns a success response' do
      get :convention, params: { enrollment_id: enrollment.name, id: subscription.to_param }

      expect(response).to have_http_status(:not_found)
    end

    describe 'with a france_connect user' do
      let(:uid) { 1 }
      let(:user) { FactoryGirl.create(:user, provider: 'france_connect', uid: uid) }

      before do
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

      describe 'user is applicant of subscription' do
        before do
          user.add_role(:applicant, subscription)
        end

        it 'returns a success response if subscription can be signed' do
          subscription.update(state: 'application_approved')
          get :convention, params: { enrollment_id: enrollment.name, id: subscription.to_param, format: :pdf }

          expect(response).to be_success
        end
      end

      describe 'user is not applicant of subscription' do
        it 'returns a success response' do
          get :convention, params: { enrollment_id: enrollment.name, id: subscription.to_param }

          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'forbids subscription creation' do
        post :create, params: { enrollment_id: enrollment.name, subscription: valid_attributes }

        expect(response).to have_http_status(:forbidden)
      end
    end

    describe 'with a france_connect user' do
      let(:uid) { 1 }
      let(:user) { FactoryGirl.create(:user, provider: 'france_connect', uid: uid) }

      before do
        user
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

      context 'with valid params' do
        it 'creates a new Subscription' do
          valid_attributes

          expect do
            post :create, params: { enrollment_id: enrollment.name, subscription: valid_attributes }
          end.to change(Subscription, :count).by(1)
        end

        it 'renders a JSON response with the new subscription' do
          post :create, params: { enrollment_id: enrollment.name, subscription: valid_attributes }

          expect(response).to have_http_status(:created)
          expect(response.content_type).to eq('application/json')
          expect(response.location).to eq(enrollment_subscription_url(enrollment, Subscription.last))
        end

        it 'user id applicant of subscription' do
          post :create, params: { enrollment_id: enrollment.name, subscription: valid_attributes }

          expect(user.has_role?(:applicant, Subscription.last)).to be_truthy
        end
      end

      context 'with invalid params' do
        it 'renders a JSON response with errors for the new subscription' do
          post :create, params: { enrollment_id: enrollment.name, subscription: invalid_attributes }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to eq('application/json')
        end
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        { agreement: false }
      end

      let(:documents_attributes) do
        [{
          attachment_type: 'Document::LegalBasis',
          attachment: fixture_file_upload(Rails.root.join('spec/resources/test.pdf'), 'application/pdf')
        }]
      end

      after do
        DocumentUploader.new(Document, :attachment).remove!
      end

      it 'renders a not found' do
        put :update, params: { enrollment_id: enrollment.name, id: subscription.to_param, subscription: new_attributes }

        subscription.reload
        expect(response).to have_http_status(:not_found)
      end

      describe 'with a france_connect user' do
        let(:uid) { 1 }
        let(:user) { FactoryGirl.create(:user, provider: 'france_connect', uid: uid) }

        before do
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

        describe 'user is not applicant of subscription' do
          it 'renders a not found' do
            put :update, params: { enrollment_id: enrollment.name, id: subscription.to_param, subscription: new_attributes }

            subscription.reload
            expect(response).to have_http_status(:not_found)
          end
        end

        describe 'user is applicant of subscription' do
          before do
            user.add_role(:applicant, subscription)
          end

          it 'updates the requested subscription' do
            put :update, params: { enrollment_id: enrollment.name, id: subscription.to_param, subscription: new_attributes }

            subscription.reload
            expect(subscription.agreement).to be_falsey
          end

          it 'renders a JSON response with the subscription' do
            put :update, params: { enrollment_id: enrollment.name, id: subscription.to_param, subscription: valid_attributes }

            expect(response).to have_http_status(:ok)
            expect(response.content_type).to eq('application/json')
          end

          it 'creates an attached legal basis' do
            expect do
              put :update, params: {
                enrollment_id: enrollment.name,
                id: subscription.to_param,
                subscription: { documents_attributes: documents_attributes }
              }
            end.to(change { subscription.documents.count })
          end
        end
      end
    end
  end

  describe 'PATCH #trigger' do
    let(:subscription) { FactoryGirl.create(:subscription, enrollment: enrollment, agreement: true) }

    # TODO test other events
    describe 'complete_application?' do
      describe 'with a france_connect user' do
        let(:uid) { 1 }
        let(:user) { FactoryGirl.create(:user, provider: 'france_connect', uid: uid) }

        before do
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

        describe 'user is applicant of subscription' do
          before do
            user.add_role(:applicant, subscription)
          end

          it 'throw a 400 if not an event' do
            patch :trigger, params: { enrollment_id: enrollment.name, id: subscription.id, event: 'boom' }

            expect(response).to have_http_status(400)
          end

          describe 'subscription can be completed' do
            before do
              enrollment.document_types.each do |document_type|
                subscription.documents.create(
                  attachment_type: document_type.name,
                  attachment: Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf')
                )
              end
            end

            it 'triggers an event' do
              patch :trigger, params: { enrollment_id: enrollment.name, id: subscription.id, event: 'fill_application' }

              expect(subscription.reload.state).to eq('filled_application')
            end

            it 'returns the subscription' do
              patch :trigger, params: { enrollment_id: enrollment.name, id: subscription.id, event: 'fill_application' }

              res = JSON.parse(response.body)
              res.delete('updated_at')
              res.delete('created_at')
              res.delete('state')
              res.delete('messages')
              res.delete('documents')
              res.delete('answers')
              res.delete('acl')

              exp = @controller.serialize(subscription)
              exp.delete('updated_at')
              exp.delete('created_at')
              exp.delete('state')
              exp.delete('messages')
              exp.delete('documents')
              exp.delete('answers')
              exp.delete('acl')

              expect(res).to eq(exp)
            end

            it 'user has application completer role' do
              patch :trigger, params: { enrollment_id: enrollment.name, id: subscription.id, event: 'fill_application' }

              expect(user.has_role?(:application_filler, subscription)).to be_truthy
            end
          end

          describe 'subscription cannot be completed' do
            let(:subscription) { FactoryGirl.create(:subscription, enrollment: enrollment) }
            it 'triggers an event' do
              patch :trigger, params: { enrollment_id: enrollment.name, id: subscription.id, event: 'fill_application' }

              expect(response).to have_http_status(:unprocessable_entity)
            end
          end
        end
      end

      describe 'with a dgfip user' do
        let(:uid) { 1 }
        let(:user) { FactoryGirl.create(:user, provider: 'dgfip', uid: uid) }

        before do
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

        it 'is unauthorized' do
          patch :trigger, params: { enrollment_id: enrollment.name, id: subscription.id, event: 'fill_application' }

          expect(response).to have_http_status(403)
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'renders a not found' do
      subscription

      delete :destroy, params: { enrollment_id: enrollment.name, id: subscription.to_param }

      expect(response).to have_http_status(:not_found)
    end

    describe 'with a france_connect user' do
      let(:uid) { 1 }
      let(:user) { FactoryGirl.create(:user, provider: 'france_connect', uid: uid) }

      before do
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

      describe 'user is not applicant of subscription' do
        it 'renders a not found' do
          subscription

          delete :destroy, params: { enrollment_id: enrollment.name, id: subscription.to_param }

          expect(response).to have_http_status(:not_found)
        end
      end

      describe 'user is applicant of subscription' do
        before do
          user.add_role(:applicant, subscription)
        end

        it 'destroys the requested subscription' do
          subscription

          expect do
            delete :destroy, params: { enrollment_id: enrollment.name, id: subscription.to_param }
          end.to change(Subscription, :count).by(-1)
        end
      end
    end
  end
end
