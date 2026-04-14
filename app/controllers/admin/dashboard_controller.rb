# app/controllers/admin/dashboard_controller.rb
class Admin::DashboardController < Admin::BaseController
  def index
    @users_count        = User.count
    @products_count     = Product.joins(:user_products).distinct.count
    @user_products_count = UserProduct.active.count

    @users              = User.order(created_at: :desc)
    @products_counts    = UserProduct.active.group(:user_id).count

    @top_products = Product
                      .joins(:user_products)
                      .where(user_products: { active: true })
                      .select("products.*, COUNT(user_products.id) AS users_count")
                      .group("products.id")
                      .order("users_count DESC")
                      .limit(20)
  end
end
