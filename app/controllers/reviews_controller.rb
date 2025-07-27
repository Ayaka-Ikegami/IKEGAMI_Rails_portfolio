class ReviewsController < ApplicationController
  before_action :authenticate_user!, except: %i[index]

  def index # 口コミ一覧
    @q = Review.includes(:store, :user).ransack(params[:q])
    @reviews = @q.result(distinct: true).order(created_at: :desc).page(params[:page]).per(20)
  end

  def new
    @review = Review.new
    @store = Store.find_by(id: params[:store_id])

    unless @store
      redirect_to root_path, alert: "店舗が見つかりません。"
      nil
    end
  end

  def create
    @review = Review.new(review_params)
    @review.user = current_user
    @store = Store.find_by(id: review_params[:store_id])

    if @review.save
      session.delete(:last_place_id)
      redirect_to store_path(@review.store.place_id), notice: "口コミを投稿しました。"
    else
      flash.now[:alert] = "口コミを投稿できませんでした。"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @review = Review.find(params[:id])
    @store = @review.store
  end

  def edit
    @review = Review.find(params[:id])

    if @review.user != current_user
      redirect_to root_path, alert: "不正なアクセスです。"
      return
    end

    @store = @review.store
  end

  def update
    @review = Review.find(params[:id])

    if @review.user != current_user
      redirect_to root_path, alert: "不正なアクセスです。"
      return
    end

    @store = @review.store
    if @review.update(review_params)
      redirect_to users_profile_path(current_user), notice: "口コミを編集しました。"
    else
      flash.now[:alert] = "口コミを編集できませんでした。"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @review = current_user.reviews.find_by(id: params[:id])
    if @review
      @review.destroy
      redirect_to users_profile_path(current_user), notice: "口コミを削除しました。"
    else
      redirect_to users_profile_path(current_user), alert: "口コミが見つかりません。"
    end
  end

  private

  def review_params
    params.require(:review).permit(:store_id, :rating, :comment)
  end
end
