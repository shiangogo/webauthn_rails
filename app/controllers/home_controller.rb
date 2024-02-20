class HomeController < ApplicationController
  def index
    if current_user
      @username = current_user.username
      render "index"
    else
      redirect_to new_registration_path
    end
  end
end
