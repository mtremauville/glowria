# app/controllers/landing_controller.rb
class LandingController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :check_onboarding

  def index
    redirect_to dashboard_path if user_signed_in?
  end
end
