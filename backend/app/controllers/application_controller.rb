class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  protect_from_forgery with: :null_session
  before_action :authenticate_user!, except: [:health]

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def authenticate_user!
    return if current_user

    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
