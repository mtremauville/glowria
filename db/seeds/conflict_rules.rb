# Recrée toutes les règles proprement à chaque seed
ConflictRule.delete_all

def ing(inci) = Ingredient.find_by!(inci_name: inci)

# Ingrédients nécessaires aux règles (casse alignée avec products.rb)
ingredients_data = [
  { name: "Vitamine C",           inci: "Ascorbic Acid" },
  { name: "Niacinamide",          inci: "Niacinamide" },
  { name: "Rétinol",              inci: "Retinol" },
  { name: "Acide Glycolique",     inci: "Glycolic Acid" },
  { name: "Acide Salicylique",    inci: "Salicylic Acid" },
  { name: "Acide Lactique",       inci: "Lactic Acid" },
  { name: "Vitamine E",           inci: "Tocopherol" },
  { name: "Peroxyde de Benzoyle", inci: "Benzoyl Peroxide" },
  { name: "Peptides",             inci: "Palmitoyl Tripeptide-1" },
  { name: "Zinc PCA",             inci: "Zinc PCA" },
  { name: "Bakuchiol",            inci: "Bakuchiol" },
  { name: "Acide Azélaïque",      inci: "Azelaic Acid" },
]

ingredients_data.each do |d|
  Ingredient.find_or_create_by!(inci_name: d[:inci]) { |i| i.name = d[:name] }
end

rules = [
  # ── CONFLITS ──────────────────────────────────────────────────────────────
  {
    rule_type: "conflict",
    a: "Retinol", b: "Glycolic Acid",
    severity: "high",
    message: "Rétinol + AHA provoque une irritation sévère et dégrade l'efficacité du rétinol.",
    recommendation: "Utilise le rétinol le soir, les AHA un autre soir. Jamais ensemble."
  },
  {
    rule_type: "conflict",
    a: "Retinol", b: "Salicylic Acid",
    severity: "high",
    message: "Rétinol + BHA = sur-exfoliation et irritations.",
    recommendation: "Alterne : rétinol lundi/jeudi, BHA mardi/vendredi."
  },
  {
    rule_type: "conflict",
    a: "Retinol", b: "Benzoyl Peroxide",
    severity: "high",
    message: "Le peroxyde de benzoyle oxyde et inactive le rétinol.",
    recommendation: "Ne jamais combiner. Utilise-les à des moments différents."
  },
  {
    rule_type: "conflict",
    a: "Ascorbic Acid", b: "Niacinamide",
    severity: "medium",
    message: "Vitamine C + Niacinamide peuvent former de la nicotinate d'ascorbyle et réduire l'efficacité des deux actifs.",
    recommendation: "Applique la Vitamine C le matin, la Niacinamide le soir."
  },
  {
    rule_type: "conflict",
    a: "Ascorbic Acid", b: "Glycolic Acid",
    severity: "medium",
    message: "Deux acides ensemble abaissent trop le pH cutané et irritent la peau.",
    recommendation: "Vitamine C le matin, AHA le soir uniquement."
  },
  {
    rule_type: "conflict",
    a: "Azelaic Acid", b: "Glycolic Acid",
    severity: "medium",
    message: "Deux exfoliants actifs ensemble sur-exfolient et fragilisent la barrière cutanée.",
    recommendation: "Acide azélaïque le matin, AHA le soir. Jamais ensemble."
  },

  # ── SYNERGIES ─────────────────────────────────────────────────────────────
  {
    rule_type: "synergy",
    a: "Ascorbic Acid", b: "Tocopherol",
    severity: "high",
    message: "La vitamine E régénère la vitamine C oxydée et multiplie sa durée d'action. Duo antioxydant de référence.",
    recommendation: "Applique-les ensemble le matin avant ton SPF pour une protection maximale."
  },
  {
    rule_type: "synergy",
    a: "Retinol", b: "Palmitoyl Tripeptide-1",
    severity: "high",
    message: "Les peptides renforcent la régénération cellulaire stimulée par le rétinol. Synergie anti-âge optimale.",
    recommendation: "Applique les peptides après le rétinol le soir pour maximiser l'effet réparateur nocturne."
  },
  {
    rule_type: "synergy",
    a: "Niacinamide", b: "Azelaic Acid",
    severity: "high",
    message: "Duo unificateur et anti-inflammatoire : efficacité renforcée contre les taches, rougeurs et imperfections.",
    recommendation: "Niacinamide en premier, acide azélaïque par-dessus pour amplifier l'effet unifiant."
  },
  {
    rule_type: "synergy",
    a: "Niacinamide", b: "Zinc PCA",
    severity: "medium",
    message: "Combo sébum et pores : le zinc régule les sécrétions grasses, la niacinamide unifie et apaise.",
    recommendation: "Association idéale pour peaux mixtes à grasses, matin et/ou soir."
  },
  {
    rule_type: "synergy",
    a: "Bakuchiol", b: "Ascorbic Acid",
    severity: "medium",
    message: "Bakuchiol et vitamine C se renforcent mutuellement pour l'éclat et l'anti-âge sans irritation.",
    recommendation: "Vitamine C le matin, bakuchiol le soir pour un effet continu sans risque."
  },
  {
    rule_type: "synergy",
    a: "Bakuchiol", b: "Lactic Acid",
    severity: "low",
    message: "Exfoliation douce et régénération cellulaire : combinaison compatible idéale pour peaux sensibles.",
    recommendation: "Acide lactique en premier pour préparer la peau, bakuchiol par-dessus ensuite."
  },
]

rules.each do |rule|
  ConflictRule.create!(
    ingredient_a:   ing(rule[:a]),
    ingredient_b:   ing(rule[:b]),
    rule_type:      rule[:rule_type],
    severity:       rule[:severity],
    message:        rule[:message],
    recommendation: rule[:recommendation]
  )
end

puts "  ✓ #{ConflictRule.conflicts.count} conflits, #{ConflictRule.synergies.count} synergies chargées"
