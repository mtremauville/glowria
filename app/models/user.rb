class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_one_attached :avatar

  has_many :user_products, dependent: :destroy
  has_many :products, through: :user_products
  has_many :routines, dependent: :destroy
  has_many :conversations, dependent: :destroy
  has_many :chat_messages, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         # for Google OmniAuth
         :omniauthable, omniauth_providers: [:google_oauth2]

  validate :password_complexity, if: -> { password.present? && provider.blank? }

  private

  def password_complexity
    return if password.match?(/\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}\z/)

    errors.add :password,
      "doit contenir au moins 8 caractères, une majuscule, une minuscule, un chiffre et un caractère spécial"
  end

  def self.from_omniauth(auth)
    # Find or create a user based on the provider and uid
    where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20] # Generate a random password
    end
  end
end
