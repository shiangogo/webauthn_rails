class SessionsController < ApplicationController
  before_action :authenticate_user, only: [:destroy]

  def new
    if current_user
      redirect_to root_path
    end
  end

  def create
    user = User.find_by(username: session_params[:username])
    session[:current_authentication] = { challenge: user.challenge, username: user.username }
  end

  def callback
  end

  def destroy
    sign_out
    redirect_to root_path
  end

  private

  def session_params
    params.require(:session).permit(:username)
  end

  def authenticate_user
    unless current_user
      redirect_to new_session_path, alert: "請先登入。"
    end
  end
end
