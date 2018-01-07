# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubscriptionsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/enrollments/1/subscriptions').to route_to('subscriptions#index', enrollment_id: '1')
    end

    it 'routes to #show' do
      expect(get: '/api/enrollments/1/subscriptions/1').to route_to('subscriptions#show', id: '1', enrollment_id: '1')
    end

    it 'routes to #convention' do
      expect(get: '/api/enrollments/1/subscriptions/1/convention').to route_to('subscriptions#convention', id: '1', enrollment_id: '1')
    end

    it 'routes to #create' do
      expect(post: '/api/enrollments/1/subscriptions').to route_to('subscriptions#create', enrollment_id: '1')
    end

    it 'routes to #update via PUT' do
      expect(put: '/api/enrollments/1/subscriptions/1').to route_to('subscriptions#update', id: '1', enrollment_id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/api/enrollments/1/subscriptions/1').to route_to('subscriptions#update', id: '1', enrollment_id: '1')
    end

    it 'routes to #trigger via PATCH' do
      expect(patch: '/api/enrollments/1/subscriptions/1/trigger').to route_to('subscriptions#trigger', id: '1', enrollment_id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/api/enrollments/1/subscriptions/1').to route_to('subscriptions#destroy', id: '1', enrollment_id: '1')
    end
  end
end
