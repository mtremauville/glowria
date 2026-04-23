# app/controllers/admin/dashboard_controller.rb
class Admin::DashboardController < Admin::BaseController
  def index
    @users_count        = User.count
    @products_count     = Product.joins(:user_products).distinct.count
    @user_products_count = UserProduct.active.count

    @users              = User.order(created_at: :desc)
    @products_counts    = UserProduct.active.group(:user_id).count

    top_product_ids = UserProduct.active
                                   .group(:product_id)
                                   .order("COUNT(*) DESC")
                                   .limit(20)
                                   .pluck(:product_id)

    counts_by_product = UserProduct.active
                                    .where(product_id: top_product_ids)
                                    .group(:product_id)
                                    .count

    @top_products = Product.where(id: top_product_ids)
                           .index_by(&:id)
                           .values_at(*top_product_ids)
                           .compact
    @top_products_counts = counts_by_product
  end
end
