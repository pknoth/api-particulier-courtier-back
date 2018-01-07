# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    FRONT_CONFIG = YAML.load_file(Rails.root.join('config/front.yml'))[Rails.env]

    def oauth2_callback
      token = request.env['omniauth.auth']['credentials'].token
      session[:token] = token
      @current_user = User.from_resource_provider_omniauth(request.env['omniauth.auth'])
      redirect_to "#{FRONT_CONFIG['callback_url']}/#{token}"
    end

    alias resource_provider oauth2_callback
    alias france_connect oauth2_callback

    # TODO: a beautifull page
    def passthru
      render status: :bad_request, json: {
        message: 'authentification provider not supported'
      }
    end

    # TODO: a beautifull page
    def failure
      render status: :unauthorized, json: {
        message: 'you are not authorized to access this api'
      }
    end

    protected

    def after_omniauth_failure_path_for(_scope)
      render :failure
    end
  end
end
