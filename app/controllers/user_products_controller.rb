class UserProductsController < ApplicationController
  before_action :set_user_product, only: [:destroy]

  def create
  end

  def destroy
    product_name = @user_product.product.name
    @user_product.destroy
    redirect_to products_path, notice: "#{product_name} retiré de ta collection."
  end

  private

  def set_user_product
    @user_product = current_user.user_products.find(params[:id])
  end
end
