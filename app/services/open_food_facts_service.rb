class OpenFoodFactsService
  BASE_URL = "https://world.openbeautyfacts.org/api/v2/product"
  # Open Beauty Facts = base dédiée cosmétiques (vs Open Food Facts pour l'alimentaire)

  def initialize(barcode)
    @barcode = barcode.to_s.strip
  end

  def fetch
    response = HTTParty.get(
      "#{BASE_URL}/#{@barcode}.json",
      headers: { "User-Agent" => "SkinCareAI/1.0 (contact@tonapp.fr)" },
      timeout: 10
    )

    return failure("Timeout ou erreur réseau") unless response.success?

    data = response.parsed_response
    return failure("Produit introuvable") if data["status"] == 0

    parse_product(data["product"])
  rescue HTTParty::Error, Net::OpenTimeout => e
    failure("Erreur réseau : #{e.message}")
  end

  private

  def parse_product(raw)
    {
      success: true,
      data: {
        name:        raw["product_name"].presence || raw["product_name_fr"] || "Produit inconnu",
        brand:       raw["brands"]&.split(",")&.first&.strip,
        barcode:     @barcode,
        category:    map_category(raw["categories_tags"]),
        image_url:   raw["image_front_url"] || raw["image_url"],
        description: raw["description"] || raw["product_description"],
        ingredients: parse_ingredients(raw)
      }
    }
  end

  def parse_ingredients(raw)
    # Open Beauty Facts fournit ingredients_tags en INCI
    inci_list = raw["ingredients_tags"]&.map { |t| t.gsub(/^[a-z]{2}:/, "").tr("-", " ").strip } || []

    # Fallback : parser ingredients_text_fr
    if inci_list.empty? && raw["ingredients_text_fr"].present?
      inci_list = raw["ingredients_text_fr"]
                    .gsub(/\[.*?\]|\(.*?\)/, "") # supprimer les précisions entre crochets
                    .split(/,|\./)
                    .map(&:strip)
                    .reject(&:blank?)
    end

    inci_list.first(30) # on limite à 30 ingrédients principaux
  end

  def map_category(tags)
    return "autre" if tags.blank?

    mapping = {
      "cleanse" => "nettoyant",
      "serum"   => "serum",
      "cream"   => "creme",
      "moistur" => "creme",
      "sunscre" => "spf",
      "toner"   => "tonique",
      "mask"    => "masque",
      "eye"     => "contour-yeux",
      "oil"     => "huile",
      "exfol"   => "exfoliant"
    }

    tags.each do |tag|
      mapping.each { |key, val| return val if tag.include?(key) }
    end

    "autre"
  end

  def failure(message)
    { success: false, error: message }
  end
end
