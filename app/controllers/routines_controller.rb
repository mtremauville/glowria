# app/controllers/routines_controller.rb
class RoutinesController < ApplicationController
  before_action :authenticate_user!

  def index
    routine_includes = { routine_steps: { user_product: { product: { product_ingredients: :ingredient } } } }
    @morning = current_user.routines.includes(routine_includes).where(period: "morning").order(generated_at: :desc).first
    @evening = current_user.routines.includes(routine_includes).where(period: "evening").order(generated_at: :desc).first
  end

  def generate
    result = RoutineGeneratorService.new(current_user).generate
    if result
      redirect_to routines_path, notice: "Routine générée avec succès ✨"
    else
      redirect_to routines_path, alert: "Erreur lors de la génération."
    end
  end
end
