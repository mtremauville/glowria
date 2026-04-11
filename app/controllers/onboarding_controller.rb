# app/controllers/onboarding_controller.rb
class OnboardingController < ApplicationController
  before_action :authenticate_user!

  def show
    redirect_to root_path if current_user.skin_type.present?
  end

  def update
    if current_user.update(onboarding_params)
      redirect_to root_path, notice: "Profil enregistré ! Bienvenue 🌿"
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def onboarding_params
    params.require(:user).permit(:skin_type, skin_goals: [], skin_concerns: [])
  end
end
