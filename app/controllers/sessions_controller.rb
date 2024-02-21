class SessionsController < ApplicationController
  before_action :authenticate_user, only: [:destroy]

  def new
    if current_user
      redirect_to root_path
    end
  end

  def create
    user = User.find_by(username: session_params[:username])
    user_get_options = user.get_options
    session[:current_authentication] = { challenge: user_get_options[:challenge], username: user.username }
    render json: user_get_options
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
