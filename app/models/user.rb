require "base64"
require "cbor"
class User < ApplicationRecord
  has_many :credentials, dependent: :destroy
  validates :username, presence: true, uniqueness: true

  after_initialize do
    self.webauthn_id ||= Base64.urlsafe_encode64(SecureRandom.random_bytes(64), padding: false)
  end

  def create_options
    {
      rp: {
        name: "Example App",
        origin: ENV["WEBAUTHN_ORIGIN"],
      },
      authenticatorSelection: { 'userVerification': 'required' },
      user: {
        id: webauthn_id,
        name: username,
        displayName: username,
      },
      challenge: challenge,
      pubKeyCredParams: [
        { type: 'public-key', alg: -7 },
        { type: 'public-key', alg: -37 },
        { type: 'public-key', alg: -257 },
      ],
      timeout: 120_000,
      attestation: "direct",
    }
  end

  def get_options
    p credentials
    {
      #TODO: this part should be finished
      allowCredentials: allowCredentials,
      challenge: challenge,
      timeout: 120_000,
      userVerification: "required"
    }
  end

  private

  def raw_challenge
    SecureRandom.random_bytes(32)
  end

  def challenge
    @raw_challenge ||= raw_challenge
    Base64.urlsafe_encode64(@raw_challenge, padding: false)
  end

  def allowCredentials
    credentials.map { |credential| { type: "public-key", id: credential.external_id } }
  end
end
