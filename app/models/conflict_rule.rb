class ConflictRule < ApplicationRecord
  belongs_to :ingredient_a
  belongs_to :ingredient_b
end
