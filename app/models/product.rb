class Product < ApplicationRecord
  has_many :product_ingredients, dependent: :destroy
  has_many :ingredients, through: :product_ingredients
  has_many :user_products
  has_many :users, through: :user_products

  has_one_attached :photo

  # Retourne l'image uploadée si présente, sinon l'URL externe (Open Food Facts)
  def display_image
    photo.attached? ? photo : image_url.presence
  end
end
