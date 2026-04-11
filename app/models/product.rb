class Product < ApplicationRecord
  has_many :product_ingredients, dependent: :destroy
  has_many :ingredients, through: :product_ingredients
  has_many :user_products
  has_many :users, through: :user_products
end
