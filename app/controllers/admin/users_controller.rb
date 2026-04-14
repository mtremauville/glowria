# app/controllers/admin/users_controller.rb
class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:edit, :update, :destroy]

  def index
    @users           = User.order(created_at: :desc)
    @products_counts = UserProduct.active.group(:user_id).count
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_create_params)
    if @user.save
      redirect_to admin_users_path, notice: "#{@user.email} a été créé avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    attrs = user_update_params
    # Ne mettre à jour le mot de passe que s'il est renseigné
    if attrs[:password].blank?
      attrs = attrs.except(:password, :password_confirmation)
    end

    if @user.update(attrs)
      redirect_to admin_users_path, notice: "#{@user.email} mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: "Impossible de supprimer votre propre compte."
      return
    end
    @user.destroy
    redirect_to admin_users_path, notice: "Compte supprimé."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_create_params
    params.require(:user).permit(:display_name, :email, :password, :password_confirmation, :admin)
  end

  def user_update_params
    params.require(:user).permit(:display_name, :email, :password, :password_confirmation, :admin)
  end
end
