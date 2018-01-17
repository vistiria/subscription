class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  validates :first_name, :last_name, :encrypted_card_number, :email, presence: true

  attr_encrypted :card_number, key: ENV['CARD_NUMBER_KEY']
end
