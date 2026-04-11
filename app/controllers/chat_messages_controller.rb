class ChatMessagesController < ApplicationController
  before_action :authenticate_user!
  include ActionController::Live  # active le streaming SSE

  def index
    @messages = current_user.chat_messages.order(created_at: :asc).last(50)
  end

  def create
    user_message = params[:message].to_s.strip
    return head :bad_request if user_message.blank?

    response.headers["Content-Type"]  = "text/event-stream"
    response.headers["Cache-Control"] = "no-cache"
    response.headers["X-Accel-Buffering"] = "no"  # désactive le buffer nginx

    sse = SSE.new(response.stream, retry: 300)

    begin
      SkincareChatService.new(current_user).chat(user_message) do |token|
        sse.write({ token: token }.to_json, event: "token")
      end
      sse.write({}.to_json, event: "done")
    rescue ActionController::Live::ClientDisconnected
      # client a fermé la connexion, pas grave
    ensure
      sse.close
    end
  end
end
