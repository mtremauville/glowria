class ChatMessage < ApplicationRecord
  belongs_to :user
  belongs_to :conversation, optional: true
end
