class UserProduct < ApplicationRecord
  belongs_to :user
  belongs_to :product
  scope :active, -> { where(active: true) }

end
