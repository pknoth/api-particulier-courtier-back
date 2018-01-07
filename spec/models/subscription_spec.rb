require 'rails_helper'

RSpec.describe Subscription, type: :model do
  let(:subscription) { FactoryGirl.create(:subscription) }
  after do
    DocumentUploader.new(Enrollment, :attachment).remove!
  end

  it 'can have messages attached to it' do
    message = FactoryGirl.create(:message)
    expect do
      subscription.attach_message(message)
    end.to change { subscription.messages.count }
  end

  describe 'workflow' do
    it 'should start on initial state' do
      expect(subscription.state).to eq('initial')
    end

    it 'can fill_application' do
      expect(subscription).to be_can_fill_application
    end

    describe 'the subscription is on filled_application state' do
      let(:subscription) { FactoryGirl.create(:subscription) }
      before do
        subscription.update_attribute(:state, 'filled_application')
      end

      describe 'messages' do
        it 'creates a message when complete_application' do
          Enrollment::DOCUMENT_TYPES.each do |document_type|
            subscription.documents.create(
              attachment_type: document_type,
              attachment: Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf')
            )
          end
          subscription.complete_application!

          message = subscription.reload.messages.last
          expect(message).to be_persisted
          expect(message.content).to eq('votre dossier a été complèté')
        end
      end

      # TODO: find a way to make it work
      # it 'cannot complete_application state if all documents uploaded' do
      #   expect(subscription.complete_application).to be_falsey
      # end

      it 'can complete_application state if all documents uploaded' do
        Enrollment::DOCUMENT_TYPES.each do |document_type|
          subscription.documents.create(
            attachment_type: document_type,
            attachment: Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf')
          )
        end

        expect(subscription.complete_application).to be_truthy
      end
    end

    describe 'the subscription is on waiting_for_approval state' do
      let(:subscription) { FactoryGirl.create(:subscription) }
      before do
        subscription.update_attribute(:state, 'waiting_for_approval')
      end

      describe 'messages' do
        it 'creates a message when application_approved' do
          expect do
            subscription.approve_application!
          end.to change { Message.count }.by(1)
        end

        it 'creates a message with good wording when application_approved' do
          subscription.approve_application!

          message = subscription.messages.last
          expect(message).to be_persisted
          expect(message.content).to eq('votre dossier a été approuvé')
        end
      end

      it 'can be refused and sent back to filled_application' do
        subscription.refuse_application!

        expect(subscription.state).to eq('filled_application')
      end

      it 'can be approved application and sent to application_approved state' do
        subscription.approve_application!

        expect(subscription.state).to eq('application_approved')
      end
    end

    describe 'the subscription is on application_approved state' do
      let(:subscription) { FactoryGirl.create(:subscription, state: 'application_approved') }

      describe 'messages' do
        it 'creates a message when application_ready' do
          subscription.sign_convention!

          message = subscription.reload.messages.last
          expect(message).to be_persisted
          expect(message.content).to eq('votre application est prête pour la mise en production')
        end
      end
      it 'can sign convention and send to application_ready state' do
        subscription.sign_convention!

        expect(subscription.state).to eq('application_ready')
      end
    end

    describe 'the subscription is on application_ready state' do
      let(:subscription) { FactoryGirl.create(:subscription, state: 'application_ready') }

      describe 'messages' do
        it 'creates a message when application_deployed' do
          subscription.deploy!

          message = subscription.reload.messages.last
          expect(message).to be_persisted
          expect(message.content).to eq('Votre application est déployée')
        end
      end

      it 'can deploy and send to deployed state' do
        subscription.deploy!

        expect(subscription.state).to eq('deployed')
      end
    end
  end

  Enrollment::DOCUMENT_TYPES.each do |document_type|
    describe document_type do
      it 'can have document' do
        expect do
          subscription.documents.create(
            attachment_type: FactoryGirl.build(:document_type, name: document_type),
            attachment: Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf')
          )
        end.to(change { subscription.documents.count })
      end

      it 'can only have a document' do
        subscription.documents.create(
          attachment_type: FactoryGirl.build(:document_type, name: document_type),
          attachment: Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf')
        )

        expect do
          subscription.documents.create(
            attachment_type: FactoryGirl.build(:document_type, name: document_type),
            attachment: Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf')
          )
        end.not_to(change { subscription.documents.count })
      end

      it 'overwrites the document' do
        subscription.documents.create(
          attachment_type: FactoryGirl.build(:document_type, name: document_type),
          attachment: Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf')
        )

        document = subscription.documents.create(
          attachment_type: FactoryGirl.build(:document_type, name: document_type),
          attachment: Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf')
        )

        expect(subscription.documents.last).to eq(document)
      end
    end
  end

  describe 'I have an enrollment with boolean field' do
    let(:field_name) { 'agreement' }
    let(:boolean) { FactoryGirl.create(:field, :boolean, name: field_name) }
    let(:enrollment) { FactoryGirl.create(:enrollment, fields: [boolean]) }
    let(:subscription) { FactoryGirl.create(:subscription, enrollment: enrollment) }

    it 'respond to <field_name>' do
      expect(subscription).to respond_to(:"#{field_name}")
    end

    it 'respond to <field_name>=' do
      expect(subscription).to respond_to(:"#{field_name}=")
    end

    it '<field_name>= methods that create an answer' do
      expect { subscription.update(agreement: true) }.to change { Answer.count }
    end
  end
end
