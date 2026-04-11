# app/services/composition_scanner_service.rb
#
# Envoie une photo d'emballage à GPT-4o-mini vision
# et extrait la liste INCI + nom/marque si visibles.
#
class CompositionScannerService
  MODEL = "gpt-4o-mini"

  PROMPT = <<~PROMPT
    Tu analyses la photo d'un emballage de produit cosmétique.

    Ta mission :
    1. Extraire la liste complète des ingrédients INCI (souvent précédée de "Ingredients:" ou "Ingrédients:").
    2. Si le nom du produit et la marque sont visibles, les identifier.

    Réponds UNIQUEMENT avec un objet JSON valide, sans markdown, sans texte autour :
    {
      "ingredients": ["AQUA", "GLYCERIN", ...],
      "product_name": "Nom du produit ou null",
      "brand": "Marque ou null"
    }

    Règles importantes :
    - Les ingrédients doivent être en MAJUSCULES, séparés, sans numérotation ni ponctuation finale.
    - Respecte l'ordre d'apparition (concentration décroissante).
    - Si la liste n'est pas visible ou lisible, retourne { "ingredients": [], "product_name": null, "brand": null }.
    - Ne génère jamais d'ingrédients de ta propre initiative.
  PROMPT

  def initialize(image_file)
    @image_file = image_file
  end

  def scan
    response = RubyLLM.chat(model: MODEL).ask(PROMPT, with: @image_file)
    parse_response(response.content)
  rescue JSON::ParserError => e
    { success: false, error: "Impossible d'analyser la réponse de l'IA." }
  rescue => e
    { success: false, error: e.message }
  end

  private

  def parse_response(content)
    # Nettoyer les éventuels marqueurs markdown
    json_text = content.gsub(/```json?\s*/i, "").gsub(/```/, "").strip
    data = JSON.parse(json_text)

    ingredients = Array(data["ingredients"])
                    .map(&:to_s)
                    .map(&:strip)
                    .reject(&:empty?)

    {
      success:      true,
      ingredients:  ingredients,
      product_name: data["product_name"].presence,
      brand:        data["brand"].presence,
      count:        ingredients.size
    }
  end
end
