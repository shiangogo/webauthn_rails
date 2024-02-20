class ApplicationController < ActionController::Base
  helper_method :current_user

  private

  def current_user
    @current_user ||= session[:user_id] && User.find_by(id: session[:user_id])
  end

  def sign_in(user)
    session[:user_id] = user.id
  end

  def sign_out(user)
    session[:user_id] = nil
  end
end
