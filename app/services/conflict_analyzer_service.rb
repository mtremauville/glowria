class ConflictAnalyzerService
  def initialize(user)
    @user = user
    @user_products = user.user_products.includes(product: { product_ingredients: :ingredient }).active
  end

  def analyze
    conflicts = []
    ingredients_by_product = build_ingredients_map

    ingredients_by_product.each do |up_id_a, ingredients_a|
      ingredients_by_product.each do |up_id_b, ingredients_b|
        next if up_id_a >= up_id_b # éviter doublons

        ingredients_a.each do |ing_a|
          ingredients_b.each do |ing_b|
            rule = find_conflict_rule(ing_a.id, ing_b.id)
            next unless rule

            conflicts << {
              user_product_a: @user_products.find { |up| up.id == up_id_a },
              user_product_b: @user_products.find { |up| up.id == up_id_b },
              ingredient_a: ing_a,
              ingredient_b: ing_b,
              severity: rule.severity,
              message: rule.message,
              recommendation: rule.recommendation
            }
          end
        end
      end
    end

    conflicts.sort_by { |c| severity_order(c[:severity]) }
  end

  private

  def build_ingredients_map
    @user_products.each_with_object({}) do |up, map|
      map[up.id] = up.product.product_ingredients
                     .sort_by(&:position)
                     .map(&:ingredient)
    end
  end

  def find_conflict_rule(id_a, id_b)
    ConflictRule.where(
      "(ingredient_a_id = ? AND ingredient_b_id = ?) OR (ingredient_a_id = ? AND ingredient_b_id = ?)",
      id_a, id_b, id_b, id_a
    ).first
  end

  def severity_order(severity)
    { "high" => 0, "medium" => 1, "low" => 2 }.fetch(severity, 3)
  end
end
