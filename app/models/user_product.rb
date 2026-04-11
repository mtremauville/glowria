class UserProduct < ApplicationRecord
  belongs_to :user
  belongs_to :product
  has_many :routine_steps, dependent: :destroy

  scope :active, -> { where(active: true) }
end
