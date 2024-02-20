class Credential < ApplicationRecord
  belongs_to :user
  validates :external_id, :public_key, :nickname, presence: true
  validates :external_id, uniqueness: true
end
