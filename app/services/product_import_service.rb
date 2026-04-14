class ProductImportService
  def initialize(user, barcode: nil, manual_data: nil, photo: nil)
    @user        = user
    @barcode     = barcode
    @manual_data = manual_data
    @photo       = photo
  end

  def import
    raw = if @barcode.present?
      result = OpenFoodFactsService.new(@barcode).fetch
      return result unless result[:success]
      result[:data]
    else
      @manual_data
    end

    ActiveRecord::Base.transaction do
      product = find_or_create_product(raw)
      product.photo.attach(@photo) if @photo.present? && !product.photo.attached?
      sync_ingredients(product, raw[:ingredients])
      user_product = attach_to_user(product)

      {
        success:      true,
        product:      product,
        user_product: user_product,
        conflicts:    detect_conflicts_for(product)
      }
    end
  rescue StandardError => e
    Rails.logger.error("ProductImportService error: #{e.class} — #{e.message}")
    { success: false, error: e.message }
  end

  private

  def find_or_create_product(data)
    # Si le produit existe déjà en base (autre user l'a déjà scanné)
    product = Product.find_by(barcode: data[:barcode]) if data[:barcode].present?
    product ||= Product.create!(
      name:        data[:name],
      brand:       data[:brand],
      barcode:     data[:barcode],
      category:    data[:category],
      image_url:   data[:image_url],
      description: data[:description]
    )
    product
  end

  def sync_ingredients(product, inci_names)
    return if inci_names.blank?

    inci_names.each_with_index do |inci_name, index|
      next if inci_name.blank?

      ingredient = Ingredient.find_or_create_by!(inci_name: inci_name.downcase) do |i|
        i.name     = inci_name.humanize
        i.function = detect_function(inci_name)
      end

      ProductIngredient.find_or_create_by!(
        product:    product,
        ingredient: ingredient
      ) { |pi| pi.position = index + 1 }
    end
  end

  def attach_to_user(product)
    up = @user.user_products.find_or_initialize_by(product: product)
    up.active     = true
    up.usage_slot = up.usage_slot.presence || "both"
    up.save!
    up
  end

  def detect_conflicts_for(product)
    # Vérifier si les ingrédients du nouveau produit conflictent
    # avec ceux déjà dans la collection de l'user
    new_ingredient_ids = product.ingredient_ids

    ConflictRule.where(
      "(ingredient_a_id IN (?) AND ingredient_b_id IN (?)) OR
       (ingredient_a_id IN (?) AND ingredient_b_id IN (?))",
      new_ingredient_ids, existing_ingredient_ids,
      existing_ingredient_ids, new_ingredient_ids
    ).includes(:ingredient_a, :ingredient_b)
  end

  def existing_ingredient_ids
    @existing_ingredient_ids ||= @user.user_products
                                      .where.not(product: nil)
                                      .joins(product: :ingredients)
                                      .pluck("ingredients.id")
                                      .uniq
  end

  # Détection simple basée sur les noms INCI connus
  FUNCTION_MAP = {
    "retinol"          => "actif",
    "niacinamide"      => "actif",
    "ascorbic acid"    => "actif",
    "glycolic acid"    => "exfoliant",
    "salicylic acid"   => "exfoliant",
    "lactic acid"      => "exfoliant",
    "hyaluronic acid"  => "hydratant",
    "glycerin"         => "hydratant",
    "ceramide"         => "hydratant",
    "zinc"             => "matifiant",
    "titanium dioxide" => "filtre-solaire",
    "aqua"             => "solvant",
    "parfum"           => "parfum"
  }.freeze

  def detect_function(inci_name)
    name_lower = inci_name.downcase
    FUNCTION_MAP.each { |key, func| return func if name_lower.include?(key) }
    "autre"
  end
end
