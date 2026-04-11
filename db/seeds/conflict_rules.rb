ingredients_data = [
  { name: "Rétinol",         inci: "retinol" },
  { name: "Acide glycolique", inci: "glycolic acid" },
  { name: "Acide salicylique",inci: "salicylic acid" },
  { name: "Acide lactique",   inci: "lactic acid" },
  { name: "Vitamine C",       inci: "ascorbic acid" },
  { name: "Niacinamide",      inci: "niacinamide" },
  { name: "Peroxyde de benzoyle", inci: "benzoyl peroxide" },
]

ingredients_data.each do |d|
  Ingredient.find_or_create_by!(inci_name: d[:inci]) { |i| i.name = d[:name] }
end

def ing(inci) = Ingredient.find_by!(inci_name: inci)

conflict_rules = [
  {
    a: "retinol", b: "glycolic acid",
    severity: "high",
    message: "Rétinol + AHA provoque une irritation sévère et dégrade l'efficacité du rétinol.",
    recommendation: "Utilise le rétinol le soir, les AHA un autre soir. Jamais ensemble."
  },
  {
    a: "retinol", b: "salicylic acid",
    severity: "high",
    message: "Rétinol + BHA = sur-exfoliation et irritations.",
    recommendation: "Alterne : rétinol lundi/jeudi, BHA mardi/vendredi."
  },
  {
    a: "retinol", b: "benzoyl peroxide",
    severity: "high",
    message: "Le peroxyde de benzoyle oxyde et inactive le rétinol.",
    recommendation: "Ne jamais combiner. Utilise-les à des moments différents."
  },
  {
    a: "ascorbic acid", b: "niacinamide",
    severity: "medium",
    message: "Vitamine C + Niacinamide peuvent former de la nicotinate d'ascorbyle et réduire l'efficacité.",
    recommendation: "Applique la Vitamine C le matin, la Niacinamide le soir."
  },
  {
    a: "ascorbic acid", b: "glycolic acid",
    severity: "medium",
    message: "Deux acides ensemble abaissent trop le pH et irritent la peau.",
    recommendation: "Utilise-les à des moments différents de la journée."
  },
]

conflict_rules.each do |rule|
  ConflictRule.find_or_create_by!(
    ingredient_a: ing(rule[:a]),
    ingredient_b: ing(rule[:b])
  ) do |r|
    r.severity       = rule[:severity]
    r.message        = rule[:message]
    r.recommendation = rule[:recommendation]
  end
end

puts "✅ #{ConflictRule.count} règles de conflits chargées"
