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
    # XXX: This part is dirty as fxxx and should be refactored
    user = User.find_by(username: session[:current_authentication]["username"])
    raise "user #{session[:current_authentication][:username]} never initiated sign up" unless user

    client_data_json = Base64.urlsafe_decode64(params[:response]["clientDataJSON"])
    client_data = JSON.parse(client_data_json)

    client_signature = Base64.urlsafe_decode64(params[:response]["signature"])
    external_id = Base64.strict_encode64(Base64.urlsafe_decode64(params[:rawId]))
    webauthn_credential = user.credentials.find_by(external_id: external_id)

    public_key = deserialize_public_key(Base64.urlsafe_decode64(webauthn_credential.public_key))

    authenticator_data_bytes = Base64.urlsafe_decode64(params[:response]["authenticatorData"])
    client_data_hash = OpenSSL::Digest::SHA256.digest(client_data_json)
    verification_data = authenticator_data_bytes + client_data_hash

    client_data_challenge = Base64.urlsafe_decode64(client_data["challenge"])
    stored_challenge = Base64.urlsafe_decode64(session[:current_authentication]["challenge"])

    if valid_signature?(public_key, client_signature, verification_data) && valid_challenge?(client_data_challenge, stored_challenge)
      sign_in(user)
    end
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

  def uncompressed_point?(data)
    data.size &&
      data.length == "\x04".length + 64 &&
      data[0] == "\x04"
  end

  def deserialize_public_key(public_key)
    if uncompressed_point?(public_key)
      COSE::Key::EC2.new(
        alg: COSE::Algorithm.by_name("ES256").id,
        crv: 1,
        x: public_key[1..32],
        y: public_key[33..-1]
      )
    else
      COSE::Key.deserialize(public_key)
    end
  end

  def valid_challenge?(client_data_challenge, expected_challenge)
    OpenSSL.secure_compare(client_data_challenge, expected_challenge)
  end

  def valid_signature?(webauthn_public_key, signature, verification_data)
    COSE::Algorithm.find(webauthn_public_key.alg).verify(webauthn_public_key.to_pkey, signature, verification_data)
  end
end
