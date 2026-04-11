# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :check_onboarding

  private

  def check_onboarding
    return unless user_signed_in?
    return if current_user.skin_type.present?
    return if request.path.start_with?("/onboarding", "/users")

    redirect_to onboarding_path
  end
end
