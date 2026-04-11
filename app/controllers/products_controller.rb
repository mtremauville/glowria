# app/controllers/products_controller.rb
class ProductsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user_products = current_user.user_products
                                 .includes(product: { product_ingredients: :ingredient })
                                 .active
                                 .order(created_at: :desc)
  end

  def new
    # Formulaire ajout manuel ou scan
  end

  # POST /products?barcode=3600523816071
  def create
    result = ProductImportService.new(
      current_user,
      barcode:     params[:barcode],
      manual_data: manual_params
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

  def manual_params
    return nil if params[:product].blank?

    params.require(:product).permit(:name, :brand, :category, :description)
          .to_h.symbolize_keys.merge(ingredients: [])
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
