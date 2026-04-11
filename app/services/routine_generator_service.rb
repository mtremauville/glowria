class RoutineGeneratorService
  SYSTEM_PROMPT = <<~PROMPT
    Tu es un expert dermatologue et cosmétologue.
    Tu analyses les produits de soin d'un utilisateur et génères une routine personnalisée
    en tenant compte de leur type de peau, leurs objectifs, et les interactions entre ingrédients.
    Réponds toujours en JSON valide avec cette structure exacte :
    {
      "morning": [
        { "product_id": 42, "order": 1, "instruction": "texte court d'application" }
      ],
      "evening": [
        { "product_id": 42, "order": 1, "instruction": "texte court d'application" }
      ],
      "summary": "conseil global en 2-3 phrases",
      "warnings": ["alerte 1", "alerte 2"]
    }
    IMPORTANT : utilise uniquement les product_id entiers fournis dans le prompt.
    Respecte l'ordre d'application (du plus léger au plus lourd).
    Ne mets pas de SPF dans la routine du soir.
    Ne combine pas rétinol et AHA/BHA dans la même routine.
  PROMPT

  def initialize(user)
    @user      = user
    @conflicts = ConflictAnalyzerService.new(user).analyze
  end

  def generate
    chat = RubyLLM.chat(model: "gpt-4o-mini")
    chat.with_instructions(SYSTEM_PROMPT)
    response = chat.ask(build_prompt)

    raw = response.content.strip
    # Extraire le JSON si l'IA enveloppe la réponse dans un bloc markdown
    raw = raw[/```(?:json)?\s*([\s\S]*?)```/, 1]&.strip || raw

    parsed = JSON.parse(raw)
    persist_routines(parsed)
    parsed
  rescue JSON::ParserError => e
    Rails.logger.error("RoutineGeneratorService JSON parse error: #{e.message}\nRaw: #{raw}")
    nil
  rescue => e
    Rails.logger.error("RoutineGeneratorService error: #{e.class} — #{e.message}")
    nil
  end

  private

  def build_prompt
    user_products = @user.user_products.includes(product: { product_ingredients: :ingredient }).active

    products_list = user_products.map do |up|
      ingredients = up.product.product_ingredients
                      .sort_by(&:position)
                      .map { |pi| pi.ingredient.name }
                      .join(", ")
      "- ID #{up.product.id} | #{up.product.name} (#{up.product.brand}) | #{up.product.category} | Slot: #{up.usage_slot} | Ingrédients: #{ingredients.presence || 'non renseignés'}"
    end.join("\n")

    conflicts_list = @conflicts.map do |c|
      "⚠️ #{c[:severity].upcase} : #{c[:ingredient_a].name} + #{c[:ingredient_b].name} — #{c[:message]}"
    end.join("\n")

    <<~PROMPT
      Utilisateur :
      - Type de peau : #{@user.skin_type.presence || 'non renseigné'}
      - Objectifs : #{Array(@user.skin_goals).join(", ").presence || 'non renseignés'}
      - Préoccupations : #{Array(@user.skin_concerns).join(", ").presence || 'non renseignées'}

      Produits disponibles (utilise ces product_id entiers dans ta réponse) :
      #{products_list.presence || "Aucun produit"}

      Conflits détectés :
      #{conflicts_list.presence || "Aucun conflit détecté"}

      Génère la routine matin et soir optimale.
    PROMPT
  end

  def persist_routines(data)
    # Précharger les user_products indexés par product_id pour éviter les N+1
    up_by_product_id = @user.user_products.active.index_by(&:product_id)

    %w[morning evening].each do |period|
      routine = @user.routines.create!(
        period:       period,
        name:         period == "morning" ? "Routine matin" : "Routine soir",
        ai_summary:   data["summary"],
        generated_at: Time.current
      )

      steps = Array(data[period])
      steps.each do |step|
        product_id   = step["product_id"].to_i
        user_product = up_by_product_id[product_id]

        unless user_product
          Rails.logger.warn("RoutineGeneratorService: product_id #{product_id} introuvable pour #{period}")
          next
        end

        routine.routine_steps.create!(
          user_product: user_product,
          order:        step["order"].to_i,
          instruction:  step["instruction"].to_s
        )
      end
    end
  end
end
