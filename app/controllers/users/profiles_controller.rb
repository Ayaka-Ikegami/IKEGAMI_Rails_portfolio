class Users::ProfilesController < ApplicationController
  before_action :set_user, only: %i[show edit update]

  def show
    @user = current_user
  end

  def edit
  end

  def update
  end

  def set_user
    @user = User.find(current_user.id)
  end

  def user_params
    params.require(:user).permit(:user_name, :profile, :avatar)
  end
end
