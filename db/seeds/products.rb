# db/seeds/products.rb
# 8 produits skincare réalistes avec ingrédients

PRODUCTS_DATA = [
  {
    name:        "Gentle Foaming Cleanser",
    brand:       "CeraVe",
    category:    "Nettoyant",
    barcode:     "3606000594357",
    description: "Nettoyant moussant doux enrichi en céramides et acide hyaluronique. Nettoie sans perturber la barrière cutanée.",
    image_url:   "https://images.ctfassets.net/1mkjkzqzizj3/2fAJvH7DfFv5P0yGKNdQaL/cerave_foaming.jpg",
    ingredients: [
      { name: "Niacinamide",       inci_name: "Niacinamide",            function: "Hydratant",   benefits: "Réduit les pores, unifie le teint",        concerns: nil },
      { name: "Acide Hyaluronique",inci_name: "Sodium Hyaluronate",     function: "Humectant",   benefits: "Hydratation profonde",                     concerns: nil },
      { name: "Céramide NP",       inci_name: "Ceramide NP",            function: "Emollient",   benefits: "Renforce la barrière cutanée",             concerns: nil }
    ],
    usage_slot: "morning"
  },
  {
    name:        "Vitamin C 15% Serum",
    brand:       "The Ordinary",
    category:    "Sérum",
    barcode:     "0769915190198",
    description: "Sérum à haute concentration en vitamine C pure. Éclat, anti-âge et uniformisation du teint.",
    image_url:   nil,
    ingredients: [
      { name: "Vitamine C",        inci_name: "Ascorbic Acid",          function: "Antioxydant", benefits: "Éclat, protection UV, synthèse de collagène", concerns: "Peut irriter les peaux sensibles" },
      { name: "Propanediol",       inci_name: "Propanediol",            function: "Solvant",     benefits: "Améliore la pénétration",                  concerns: nil },
      { name: "Vitamine E",        inci_name: "Tocopherol",             function: "Antioxydant", benefits: "Stabilise la vitamine C, nourrissant",     concerns: nil }
    ],
    usage_slot: "morning"
  },
  {
    name:        "AHA 30% + BHA 2% Peeling Solution",
    brand:       "The Ordinary",
    category:    "Exfoliant",
    barcode:     "769915190396",
    description: "Solution exfoliante chimique concentrée. Améliore la texture, réduit les pores et les imperfections.",
    image_url:   nil,
    ingredients: [
      { name: "Acide Glycolique",  inci_name: "Glycolic Acid",          function: "Exfoliant",   benefits: "Lisse la texture, éclat",                  concerns: "Ne pas utiliser avec rétinol ni vitamine C" },
      { name: "Acide Salicylique", inci_name: "Salicylic Acid",         function: "Exfoliant",   benefits: "Désobstrue les pores, anti-acné",           concerns: "Ne pas combiner avec AHA à haute dose" },
      { name: "Acide Lactique",    inci_name: "Lactic Acid",            function: "Exfoliant",   benefits: "Hydratant et exfoliant doux",               concerns: nil }
    ],
    usage_slot: "evening"
  },
  {
    name:        "Moisturizing Cream",
    brand:       "CeraVe",
    category:    "Hydratant",
    barcode:     "3606000594593",
    description: "Crème hydratante riche non comédogène. Idéale pour peaux sèches à très sèches, visage et corps.",
    image_url:   nil,
    ingredients: [
      { name: "Céramide NP",       inci_name: "Ceramide NP",            function: "Emollient",   benefits: "Renforce la barrière cutanée",             concerns: nil },
      { name: "Céramide AP",       inci_name: "Ceramide AP",            function: "Emollient",   benefits: "Réparation de la barrière lipidique",      concerns: nil },
      { name: "Acide Hyaluronique",inci_name: "Sodium Hyaluronate",     function: "Humectant",   benefits: "Hydratation profonde",                     concerns: nil }
    ],
    usage_slot: "both"
  },
  {
    name:        "Retinol 0.5% in Squalane",
    brand:       "The Ordinary",
    category:    "Sérum",
    barcode:     "769915190457",
    description: "Sérum rétinol 0.5% dans une base de squalane. Anti-âge, lissant, régénérant cellulaire.",
    image_url:   nil,
    ingredients: [
      { name: "Rétinol",           inci_name: "Retinol",                function: "Anti-âge",    benefits: "Renouvellement cellulaire, anti-rides",    concerns: "Ne pas utiliser avec AHA/BHA ni vitamine C" },
      { name: "Squalane",          inci_name: "Squalane",               function: "Emollient",   benefits: "Hydratant léger, non comédogène",          concerns: nil }
    ],
    usage_slot: "evening"
  },
  {
    name:        "Daily Sun Defense SPF50+",
    brand:       "La Roche-Posay",
    category:    "Protection solaire",
    barcode:     "3337875519052",
    description: "Crème solaire SPF50+ texture légère invisible. Protection UVA/UVB, convient aux peaux sensibles.",
    image_url:   nil,
    ingredients: [
      { name: "Mexoryl SX",        inci_name: "Ecamsule",               function: "Filtre UV",   benefits: "Protection UVA large spectre",             concerns: nil },
      { name: "Niacinamide",       inci_name: "Niacinamide",            function: "Hydratant",   benefits: "Anti-rougeurs, pores resserrés",           concerns: nil },
      { name: "Tocophérol",        inci_name: "Tocopherol",             function: "Antioxydant", benefits: "Protège des radicaux libres",              concerns: nil }
    ],
    usage_slot: "morning"
  },
  {
    name:        "Hydrating Toner",
    brand:       "Paula's Choice",
    category:    "Tonique",
    barcode:     "5035832100661",
    description: "Tonique hydratant sans alcool. Prépare la peau à absorber les actifs suivants, rééquilibre le pH.",
    image_url:   nil,
    ingredients: [
      { name: "Niacinamide",       inci_name: "Niacinamide",            function: "Hydratant",   benefits: "Unifiant, anti-pores",                     concerns: nil },
      { name: "Acide Hyaluronique",inci_name: "Sodium Hyaluronate",     function: "Humectant",   benefits: "Hydratation multi-couche",                 concerns: nil },
      { name: "Panthénol",         inci_name: "Panthenol",              function: "Emollient",   benefits: "Apaisant, cicatrisant",                    concerns: nil }
    ],
    usage_slot: "both"
  },
  {
    name:        "Eye Cream Caffeine Solution",
    brand:       "The Ordinary",
    category:    "Contour des yeux",
    barcode:     "769915190518",
    description: "Solution contour des yeux à la caféine 5% et EGCG. Réduit les poches et cernes.",
    image_url:   nil,
    ingredients: [
      { name: "Caféine",           inci_name: "Caffeine",               function: "Décongestionnant", benefits: "Réduit les poches et gonflements",    concerns: nil },
      { name: "EGCG",              inci_name: "Epigallocatechin Gallyl Glucoside", function: "Antioxydant", benefits: "Anti-âge, antioxydant puissant", concerns: nil },
      { name: "Acide Hyaluronique",inci_name: "Sodium Hyaluronate",     function: "Humectant",   benefits: "Hydratation zone sensible",               concerns: nil }
    ],
    usage_slot: "both"
  }
].freeze

puts "  → Création des produits..."

PRODUCTS_DATA.each do |data|
  ingredients_data = data.delete(:ingredients)
  usage_slot       = data.delete(:usage_slot)

  product = Product.find_or_create_by!(barcode: data[:barcode]) do |p|
    p.assign_attributes(data)
  end

  ingredients_data.each_with_index do |ing_data, idx|
    ingredient = Ingredient.find_or_create_by!(inci_name: ing_data[:inci_name]) do |i|
      i.name     = ing_data[:name]
      i.function = ing_data[:function]
      i.benefits = ing_data[:benefits]
      i.concerns = ing_data[:concerns]
    end

    ProductIngredient.find_or_create_by!(product: product, ingredient: ingredient) do |pi|
      pi.position = idx + 1
    end
  end

  # Associer au premier utilisateur si présent
  if (user = User.first)
    UserProduct.find_or_create_by!(user: user, product: product) do |up|
      up.usage_slot = usage_slot
      up.active     = true
    end
  end
end

puts "  ✓ #{Product.count} produits, #{Ingredient.count} ingrédients"
