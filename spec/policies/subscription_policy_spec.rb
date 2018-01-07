# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubscriptionPolicy do
  subject { described_class }

  permissions :create? do
    let(:user) { FactoryGirl.create(:user) }
    let(:fc_user) { FactoryGirl.create(:user, provider: 'france_connect') }
    let(:subscription) { FactoryGirl.create(:subscription) }

    it 'deny access if not france_connected_user' do
      expect(subject).not_to permit(user, subscription)
    end

    it 'allow access if france_connected_user' do
      expect(subject).to permit(fc_user, subscription)
    end
  end

  permissions :update? do
    let(:user) { FactoryGirl.create(:user) }
    let(:fc_user) { FactoryGirl.create(:user, provider: 'france_connect') }
    let(:subscription) { FactoryGirl.create(:subscription) }

    it 'deny access if not france_connected_user' do
      expect(subject).not_to permit(user, subscription)
    end

    it 'deny access if france_connected_user and cannot neither complete application, nor fill application' do
      expect(subscription).to receive(:can_complete_application?).and_return(false)
      expect(subscription).to receive(:can_fill_application?).and_return(false)
      expect(subject).not_to permit(fc_user, subscription)
    end

    it 'allow access if france_connected_user and can complete application but not fill application' do
      expect(subscription).to receive(:can_fill_application?).and_return(false)
      expect(subscription).to receive(:can_complete_application?).and_return(true)
      expect(subject).to permit(fc_user, subscription)
    end

    describe 'I have an applicant field' do
      let(:applicant) { FactoryGirl.create(:field, :applicant) }
      let(:enrollment) { FactoryGirl.create(:enrollment, fields: [applicant]) }
      let(:subscription) { FactoryGirl.create(:subscription, enrollment: enrollment) }

      it 'deny access if france_connected_user and can sign convention without applicant' do
        expect(subscription).to receive(:can_fill_application?).and_return(false)
        expect(subscription).to receive(:can_sign_convention?).and_return(true)
        expect(subject).not_to permit(fc_user, subscription)
      end

      it 'allow access if france_connected_user and can sign convention with applicant' do
        expect(subscription).to receive(:can_sign_convention?).and_return(true)
        subscription.applicant = { 'email' => 'test@test.test' }
        expect(subject).to permit(fc_user, subscription)
      end
    end
  end

  permissions :fill_application? do
    let(:user) { FactoryGirl.create(:user) }
    let(:subscription) { FactoryGirl.create(:subscription) }

    it 'deny access if not frnace connect user' do
      expect(subject).not_to permit(user, subscription)
    end

    describe 'I have a france connect user' do
      let(:user) { FactoryGirl.create(:user, provider: 'france_connect') }

      it 'deny access if it cannot fill application' do
        expect(subscription).to receive(:can_fill_application?).and_return(false)

        expect(subject).not_to permit(user, subscription)
      end

      it 'allow access if it can fill application' do
        expect(subscription).to receive(:can_fill_application?).and_return(true)

        expect(subject).to permit(user, subscription)
      end
    end
  end

  permissions :complete_application? do
    let(:user) { FactoryGirl.create(:user) }
    let(:subscription) { FactoryGirl.create(:subscription) }

    it 'deny access if not frnace connect user' do
      expect(subject).not_to permit(user, subscription)
    end

    describe 'I have a france connect user' do
      let(:user) { FactoryGirl.create(:user, provider: 'france_connect') }

      it 'deny access if it cannot complete application' do
        expect(subscription).to receive(:can_complete_application?).and_return(false)

        expect(subject).not_to permit(user, subscription)
      end

      it 'allow access if it can complete application' do
        expect(subscription).to receive(:can_complete_application?).and_return(true)

        expect(subject).to permit(user, subscription)
      end
    end
  end

  permissions :deploy? do
    let(:user) { FactoryGirl.create(:user) }
    let(:subscription) { FactoryGirl.create(:subscription) }

    it 'deny access if not frnace connect user' do
      expect(subject).not_to permit(user, subscription)
    end

    describe 'I have a france connect user' do
      let(:user) { FactoryGirl.create(:user, provider: 'france_connect') }

      it 'deny access if it cannot deploy' do
        expect(subscription).to receive(:can_deploy?).and_return(false)

        expect(subject).not_to permit(user, subscription)
      end

      it 'allow access if it can deploy' do
        expect(subscription).to receive(:can_deploy?).and_return(true)

        expect(subject).to permit(user, subscription)
      end
    end
  end

  permissions :approve_application? do
    let(:user) { FactoryGirl.create(:user) }
    let(:subscription) { FactoryGirl.create(:subscription) }

    it 'deny access if not dgfip user' do
      expect(subject).not_to permit(user, subscription)
    end

    describe 'I have a dgfip user' do
      let(:user) { FactoryGirl.create(:user, provider: 'dgfip', scopes: ['dgfip']) }

      it 'deny access if it cannot approve application' do
        expect(subscription).to receive(:can_approve_application?).and_return(false)

        expect(subject).not_to permit(user, subscription)
      end

      it 'allow access if it can approve application' do
        expect(subscription).to receive(:can_approve_application?).and_return(true)

        expect(subject).to permit(user, subscription)
      end
    end
  end

  permissions :refuse_application? do
    let(:user) { FactoryGirl.create(:user) }
    let(:subscription) { FactoryGirl.create(:subscription) }

    it 'deny access if not dgfip user' do
      expect(subject).not_to permit(user, subscription)
    end

    describe 'I have a dgfip user' do
      let(:user) { FactoryGirl.create(:user, provider: 'dgfip', scopes: ['dgfip']) }

      it 'deny access if it cannot refuse application' do
        expect(subscription).to receive(:can_refuse_application?).and_return(false)

        expect(subject).not_to permit(user, subscription)
      end

      it 'allow access if it can refuse application' do
        expect(subscription).to receive(:can_refuse_application?).and_return(true)

        expect(subject).to permit(user, subscription)
      end
    end
  end
end
