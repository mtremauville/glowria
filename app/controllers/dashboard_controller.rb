# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user_products     = current_user.user_products.includes(:product).where(active: true)
    @conflicts         = ConflictAnalyzerService.new(current_user).analyze
    @morning_routine   = current_user.routines.where(period: "morning").order(generated_at: :desc).first
    @evening_routine   = current_user.routines.where(period: "evening").order(generated_at: :desc).first
    @recent_messages   = current_user.chat_messages.order(created_at: :desc).limit(3)

  end
end
