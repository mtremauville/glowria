class ConflictRule < ApplicationRecord
  belongs_to :ingredient_a, class_name: "Ingredient"
  belongs_to :ingredient_b, class_name: "Ingredient"

  validates :severity, inclusion: { in: %w[low medium high] }
end
