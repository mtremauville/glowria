class Conversation < ApplicationRecord
  belongs_to :user
  has_many :chat_messages, dependent: :destroy

  validates :title, presence: true

  scope :recent, -> { order(updated_at: :desc) }

  def set_title_from(message_content)
    update(title: message_content.to_s.truncate(60))
  end
end
