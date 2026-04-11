class RoutineGeneratorService
  SYSTEM_PROMPT = <<~PROMPT
    Tu es un expert dermatologue et cosmétologue.
    Tu analyses les produits de soin d'un utilisateur et génères une routine personnalisée
    en tenant compte de leur type de peau, leurs objectifs, et les interactions entre ingrédients.
    Réponds toujours en JSON valide avec cette structure exacte :
    {
      "morning": [
        { "product_id": "uuid", "order": 1, "instruction": "texte court" }
      ],
      "evening": [
        { "product_id": "uuid", "order": 1, "instruction": "texte court" }
      ],
      "summary": "conseil global en 2-3 phrases",
      "warnings": ["alerte 1", "alerte 2"]
    }
  PROMPT

  def initialize(user)
    @user = user
    @conflicts = ConflictAnalyzerService.new(user).analyze
  end

  def generate
    chat = RubyLLM.chat(model: "gpt-4o-mini")
    chat.with_instructions(SYSTEM_PROMPT)
    response = chat.ask(build_prompt)

    parsed = JSON.parse(response.content)
    persist_routines(parsed)
    parsed
  rescue JSON::ParserError => e
    Rails.logger.error("RoutineGeneratorService JSON error: #{e.message}")
    nil
  end

  private

  def build_prompt
    products_list = @user.user_products.includes(product: :product_ingredients).active.map do |up|
      ingredients = up.product.product_ingredients.includes(:ingredient).map { |pi| pi.ingredient.name }.join(", ")
      "- #{up.product.name} (#{up.product.category}) | Ingrédients : #{ingredients}"
    end.join("\n")

    conflicts_list = @conflicts.map do |c|
      "⚠️ #{c[:severity].upcase} : #{c[:ingredient_a].name} + #{c[:ingredient_b].name} — #{c[:message]}"
    end.join("\n")

    <<~PROMPT
      Utilisateur :
      - Type de peau : #{@user.skin_type}
      - Objectifs : #{Array(@user.skin_goals).join(", ")}
      - Préoccupations : #{Array(@user.skin_concerns).join(", ")}

      Produits disponibles :
      #{products_list}

      Conflits détectés :
      #{conflicts_list.presence || "Aucun conflit détecté"}

      Génère la routine matin et soir optimale en respectant les règles de superposition (du plus léger au plus lourd) et en évitant les conflits.
    PROMPT
  end

  def persist_routines(data)
    %w[morning evening].each do |period|
      routine = @user.routines.create!(
        period: period,
        name: "Routine #{period == 'morning' ? 'matin' : 'soir'}",
        ai_summary: data["summary"],
        generated_at: Time.current
      )

      data[period]&.each do |step|
        user_product = @user.user_products.joins(:product)
                            .find_by(products: { id: step["product_id"] })
        next unless user_product

        routine.routine_steps.create!(
          user_product: user_product,
          order: step["order"],
          instruction: step["instruction"]
        )
      end
    end
  end
end
