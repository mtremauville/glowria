class ConflictRule < ApplicationRecord
  belongs_to :ingredient_a, class_name: "Ingredient"
  belongs_to :ingredient_b, class_name: "Ingredient"

  validates :rule_type, inclusion: { in: %w[conflict synergy] }
  validates :severity,  inclusion: { in: %w[low medium high] }

  scope :conflicts,  -> { where(rule_type: "conflict") }
  scope :synergies,  -> { where(rule_type: "synergy") }
end
