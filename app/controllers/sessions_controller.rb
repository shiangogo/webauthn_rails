class SessionsController < ApplicationController
  def new
  end

  def create
  end

  def callback
  end

  def destroy
    sign_out(current_user)
    redirect_to root_path
  end
end
