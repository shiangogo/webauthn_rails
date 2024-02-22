class RegistrationsController < ApplicationController
  def new
    if current_user
      redirect_to root_path
    end
  end

  def create
    user = User.new(username: params[:registration][:username])

    if user.valid?
      session[:current_registration] = { challenge: user.create_options[:challenge], user_attributes: user.attributes }

      @create_options = user.create_options
      render json: @create_options
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def callback
    current_registration = session[:current_registration]
    user_attributes = current_registration["user_attributes"]

    user = User.create!(user_attributes)

    begin
      # Decode response.attestationObject
      attestation_object_base64 = params[:response][:attestationObject]
      attestation_object_binary = Base64.urlsafe_decode64(attestation_object_base64)
      decoded_attestation_object = CBOR.decode(attestation_object_binary)

      # extract authData
      # 32 bytes, rpIdHash
      # 1 byte, flags (includes the `AT` and `ED` flags)
      # 4 bytes, signCount
      # ? bytes, attestedCredentialData
      # Assuming the `AT` flag is true, the attestedCredentialData strats from byte 37, and contains:
        # 16 bytes, aaguid
        # 2 bytes, credentialIdLength (bytes 53-55, seen in many implementations)
        # credentialIdLength bytes, credentialId
        # ? bytes, credentialPublicKey
      auth_data = decoded_attestation_object["authData"]
      id_len_bytes = auth_data[53..54]
      credential_id_length = id_len_bytes.unpack('S>').first

      credential_id = Base64.strict_encode64(auth_data[55, credential_id_length])
      public_key_bytes = auth_data[(55 + credential_id_length)..-1]

      public_key = Base64.urlsafe_encode64(public_key_bytes, padding: false)

      credential = user.credentials.build(
        external_id: credential_id,
        nickname: params[:credential_nickname],
        public_key: public_key
      )

      if credential.save
        sign_in(user)
        render json: { status: "ok" }, status: :ok
      else
        render json: "Couldn't register your security key", status: :unprocessable_entity
      end
    rescue => e
      puts "Error: #{e.message}"
    ensure
      session.delete(:current_registration)
    end
  end
end
