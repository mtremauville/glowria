class Routine < ApplicationRecord
  belongs_to :user
  has_many :routine_steps, dependent: :destroy

end
