class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :user_products, dependent: :destroy
  has_many :products, through: :user_products
  has_many :routines, dependent: :destroy
  has_many :chat_messages, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
