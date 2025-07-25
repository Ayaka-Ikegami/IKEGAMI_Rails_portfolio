class Users::ProfilesController < ApplicationController
  before_action :set_user, only: %i[show]

  def show
    @user = current_user
    @reviews = @user.reviews.includes(:store).order(created_at: :desc)
  end

  def set_user
    @user = User.find(current_user.id)
  end

  def user_params
    params.require(:user).permit(:user_name, :profile, :avatar)
  end
end
