# frozen_string_literal: true

Rails.application.routes.draw do
  scope :api do
    resources :enrollments do
      resources :subscriptions do
        member do
          get :convention
          patch :trigger
        end
      end
    end

    resources :subscriptions, only: [:index, :show, :update] do
      member do
        get :convention
        patch :trigger
      end
    end

    resources :messages
    get 'users/access_denied'
  end

  devise_scope :api do
    devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  end

  get '/uploads/:model/:mounted_as/:id/:filename', to: 'documents#show'
end
