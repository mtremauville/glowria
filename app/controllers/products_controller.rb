# app/controllers/products_controller.rb
class ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [:edit, :update, :purge_photo]

  def index
    @user_products = current_user.user_products
                                 .includes(product: { product_ingredients: :ingredient })
                                 .active
                                 .order(created_at: :desc)
  end

  def show
    @product = Product.includes(product_ingredients: :ingredient).find(params[:id])
    @ingredients = @product.product_ingredients.includes(:ingredient).order(:position)
    @active_ingredients = @ingredients.select { |pi| pi.ingredient.function.present? || pi.ingredient.benefits.present? }
  end

  def new
    # Formulaire ajout manuel ou scan
  end

  def edit
    @ingredients_text = @product.product_ingredients
                                 .order(:position)
                                 .map { |pi| pi.ingredient.inci_name.presence || pi.ingredient.name }
                                 .join("\n")
  end

  def update
    ActiveRecord::Base.transaction do
      @product.update!(product_update_params)
      if params.dig(:product, :remove_photo) == "1"
        @product.photo.purge
      elsif params.dig(:product, :photo).present?
        @product.photo.attach(params.dig(:product, :photo))
      end
      resync_ingredients if params[:ingredients_text].present?
    end

    redirect_to product_path(@product), notice: "#{@product.name} mis à jour ✨"
  rescue ActiveRecord::RecordInvalid => e
    @ingredients_text = params[:ingredients_text]
    flash.now[:alert] = e.message
    render :edit, status: :unprocessable_entity
  end

  # POST /products?barcode=3600523816071
  def create
    result = ProductImportService.new(
      current_user,
      barcode:     params[:barcode],
      manual_data: manual_params,
      photo:       params.dig(:product, :photo)
    ).import

    if result[:success]
      flash_conflicts(result[:conflicts])
      redirect_to products_path,
        notice: "#{result[:product].name} ajouté à ta collection ✨"
    else
      flash.now[:alert] = result[:error]
      render :new, status: :unprocessable_entity
    end
  end

  def purge_photo
    @product.photo.purge
    redirect_to product_path(@product), notice: "Photo supprimée."
  end

  # POST /products/scan_composition (appelé par Stimulus via AJAX)
  def scan_composition
    unless params[:image].present?
      return render json: { success: false, error: "Aucune image reçue." }, status: :bad_request
    end

    result = CompositionScannerService.new(params[:image]).scan
    render json: result
  end

  # GET /products/lookup?barcode=3600523816071 (appelé par Stimulus live)
  def lookup
    result = OpenFoodFactsService.new(params[:barcode]).fetch

    if result[:success]
      render json: result[:data]
    else
      render json: { error: result[:error] }, status: :not_found
    end
  end

  private

  def product_update_params
    params.require(:product).permit(:name, :brand, :category, :description, :barcode, :remove_photo)
  end

  def resync_ingredients
    inci_names = params[:ingredients_text].split("\n").map(&:strip).reject(&:blank?)
    @product.product_ingredients.destroy_all
    inci_names.each_with_index do |inci_name, index|
      ingredient = Ingredient.find_or_create_by!(inci_name: inci_name.downcase) do |i|
        i.name = inci_name.humanize
      end
      @product.product_ingredients.create!(ingredient: ingredient, position: index + 1)
    end
  end

  def set_product
    @product = current_user.admin? ? Product.find(params[:id]) : current_user.products.find(params[:id])
  end

  def manual_params
    return nil if params[:product].blank?

    product_params = params.require(:product)
                           .permit(:name, :brand, :category, :description, :barcode, :photo, ingredients: [])
                           .to_h.symbolize_keys

    # Les ingrédients viennent soit de product[ingredients][] (scan composition)
    # soit sont vides (saisie manuelle)
    product_params[:ingredients] = Array(product_params[:ingredients]).map(&:to_s).reject(&:blank?)
    product_params
  end

  def flash_conflicts(conflicts)
    return if conflicts.blank?

    high = conflicts.select { |c| c.severity == "high" }
    flash[:warning] = if high.any?
      "⚠️ #{high.count} conflit(s) sérieux détecté(s) avec ta collection !"
    else
      "#{conflicts.count} interaction(s) détectée(s). Consulte l'analyse."
    end
  end
end
