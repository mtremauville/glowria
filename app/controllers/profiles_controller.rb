class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
  end

  def avatar
    current_user.avatar.purge
    redirect_to profile_path, notice: "Photo supprimée."
  end

  def update
    if current_user.update(profile_params)
      redirect_to profile_path, notice: "Profil mis à jour ✓"
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:skin_type, :avatar, skin_goals: [], skin_concerns: [])
  end
end
