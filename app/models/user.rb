class User < ApplicationRecord
  has_many :credentials, dependent: :destroy
  validates :username, presence: true, uniqueness: true

  after_initialize do
    self.webauthn_id ||= encode(SecureRandom.random_bytes(64))
  end

  def create_options
    {
      rp: {
        name: "Example App",
        origin: "http://localhost:3000",
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
    }
  end

  def raw_challenge
    SecureRandom.random_bytes(32)
  end

  def challenge
    @raw_challenge ||= raw_challenge
    encode(@raw_challenge)
  end
end
