# app/services/skincare_chat_service.rb
class SkincareChatService
  SYSTEM_PROMPT = <<~PROMPT
    Tu es un assistant expert en skincare, bienveillant et précis.
    Tu connais les interactions entre ingrédients cosmétiques, les routines de soin,
    et les types de peau. Tu réponds toujours en français, de façon concise (3-5 phrases max).
    Si une combinaison est dangereuse, tu le signales clairement avec ⚠️.
    Si tu recommandes un produit absent de la collection, tu précises que c'est une suggestion externe.
  PROMPT

  MODEL = "gpt-4o-mini"

  def initialize(user)
    @user = user
  end

  def chat(user_message, image: nil, &block)
    stored_content = user_message.presence || "📷 Photo envoyée"
    @user.chat_messages.create!(role: "user", content: stored_content)

    full_response = ""

    chat_instance = RubyLLM.chat(model: MODEL)
    chat_instance.with_instructions(SYSTEM_PROMPT + "\n\n" + user_context)

    prompt   = user_message.presence || "Analyse cette photo de produit ou d'emballage et donne ton avis skincare."
    ask_opts = image ? { with: image } : {}

    chat_instance.ask(prompt, **ask_opts) do |chunk|
      token = chunk.content.to_s
      next if token.blank?
      full_response += token
      block.call(token) if block_given?
    end

    @user.chat_messages.create!(role: "assistant", content: full_response)
    full_response
  end

  private

  def user_context
    products = @user.user_products.includes(:product).where(active: true).map do |up|
      "#{up.product.name} (#{up.product.category}, usage: #{up.usage_slot})"
    end.join(", ")

    <<~CTX
      Contexte utilisateur :
      - Type de peau : #{@user.skin_type}
      - Objectifs : #{Array(@user.skin_goals).join(", ")}
      - Collection actuelle : #{products.presence || "aucun produit encore"}
    CTX
  end

  def history
    @user.chat_messages.order(created_at: :asc).last(10)
  end
end
