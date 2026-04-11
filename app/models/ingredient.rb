class Ingredient < ApplicationRecord
  has_many :product_ingredients
  has_many :products, through: :product_ingredients
  has_many :conflict_rules_as_a, class_name: "ConflictRule", foreign_key: :ingredient_a_id, dependent: :destroy
  has_many :conflict_rules_as_b, class_name: "ConflictRule", foreign_key: :ingredient_b_id, dependent: :destroy
end
