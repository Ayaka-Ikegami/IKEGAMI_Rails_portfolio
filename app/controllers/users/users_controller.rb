class Users::UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @reviews = @user.reviews.includes(:store).order(created_at: :desc)
  end
end
