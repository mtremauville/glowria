class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false, default: "Nouvelle conversation"
      t.timestamps
    end

    add_reference :chat_messages, :conversation, null: true, foreign_key: true

    # Migrate existing messages: one conversation per user
    reversible do |dir|
      dir.up do
        execute <<~SQL
          INSERT INTO conversations (user_id, title, created_at, updated_at)
          SELECT DISTINCT user_id,
                 'Historique',
                 MIN(created_at),
                 MAX(updated_at)
          FROM   chat_messages
          WHERE  user_id IS NOT NULL
          GROUP  BY user_id
        SQL

        execute <<~SQL
          UPDATE chat_messages
          SET    conversation_id = (
            SELECT id FROM conversations
            WHERE  conversations.user_id = chat_messages.user_id
            LIMIT  1
          )
          WHERE  conversation_id IS NULL
        SQL
      end
    end
  end
end
