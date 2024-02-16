class HomeController < ApplicationController
  def index
    redirect_to new_registration_path
  end
end
