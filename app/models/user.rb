class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_one_attached :avatar

  has_many :user_products, dependent: :destroy
  has_many :products, through: :user_products
  has_many :routines, dependent: :destroy
  has_many :conversations, dependent: :destroy
  has_many :chat_messages, dependent: :destroy

  google_providers = ENV["GOOGLE_CLIENT_ID"].present? ? [:google_oauth2] : []
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: google_providers

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
      user.email    = auth.info.email
      user.password = Devise.friendly_token[0, 20]
    end.tap(&:save!)
  end

  # Compte Google : pas de mot de passe requis
  def password_required?
    super && provider.blank?
  end
end
