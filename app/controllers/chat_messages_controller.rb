class ChatMessagesController < ApplicationController
  before_action :authenticate_user!
  include ActionController::Live

  def index
    @conversations = current_user.conversations.recent
    @messages = []
    @conversation = nil
  end

  def create
    user_message = params[:message].to_s.strip
    image        = params[:image]

    return head :bad_request if user_message.blank? && image.blank?

    # Find or create conversation
    conversation = if params[:conversation_id].present?
      current_user.conversations.find_by(id: params[:conversation_id])
    end
    conversation ||= current_user.conversations.create!(title: "Nouvelle conversation")

    # Auto-title on first real message
    if conversation.title == "Nouvelle conversation" && user_message.present?
      conversation.set_title_from(user_message)
    end

    response.headers["Content-Type"]      = "text/event-stream"
    response.headers["Cache-Control"]     = "no-cache"
    response.headers["X-Accel-Buffering"] = "no"

    sse = SSE.new(response.stream, retry: 300)

    begin
      # Send conversation_id back to client so it can update the URL
      sse.write({ conversation_id: conversation.id }.to_json, event: "init")

      SkincareChatService.new(current_user, conversation).chat(user_message, image: image) do |token|
        sse.write({ token: token }.to_json, event: "token")
      end
      sse.write({}.to_json, event: "done")
    rescue ActionController::Live::ClientDisconnected
      # client closed the connection
    rescue => e
      Rails.logger.error("ChatMessagesController error: #{e.class} — #{e.message}")
      sse.write({ error: "Une erreur est survenue. Réessaie dans un instant." }.to_json, event: "error")
    ensure
      sse.close
    end
  end
end
