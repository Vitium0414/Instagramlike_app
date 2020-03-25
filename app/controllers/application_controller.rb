class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  
  def authenticate_user!
    session[:user_return_to] = env['PATH_INFO']
    redirect_to user_omniauth_authorize_path(:facebook) unless user_signed_in?
  end
  
  private
    def logged_in_user
      unless logged_in?
      store_location
      flash[:danger] = "ログインしてください"
      redirect_to login_url
      end
    end
end
