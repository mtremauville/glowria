class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:show, :destroy]

  def index
    redirect_to chat_messages_path
  end

  def show
    @conversations = current_user.conversations.recent
    @messages = @conversation.chat_messages.order(created_at: :asc)
  end

  def destroy
    @conversation.destroy
    redirect_to chat_messages_path, notice: "Conversation supprimée."
  end

  private

  def set_conversation
    @conversation = current_user.conversations.find(params[:id])
  end
end
