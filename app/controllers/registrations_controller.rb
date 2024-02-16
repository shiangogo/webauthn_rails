class RegistrationsController < ApplicationController
  def new
  end

  def create
    user = User.new(username: params[:registration][:username])

    if user.valid?
      session[:current_registration] = { challenge: user.create_options[:challenge], user_attributes: user.attributes }

      @create_options = user.create_options
      # respond_to do |format|
      #   format.js { render 'registrations/create'}
      # end
      respond_to do |format|
        format.html { redirect_to new_registration_path }
      format.json { render json: @create_options }
      end

      # render json: @create_options
    end
  end

  def callback
    p params
    # user = User.create!(session[:current_registration][:user_attributes])
  end

  private

  def raw_challenge
    SecureRandom.random_bytes(32)
  end
end

