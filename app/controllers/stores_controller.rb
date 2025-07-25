require "net/http"
require "uri"
require "json"

class StoresController < ApplicationController
  def index
    # 検索フォーム表示
  end

  def search
    api_key = ENV["PLACES_API_KEY"]
    keyword = params[:keyword].presence || "うどん" # 検索デフォルト「うどん」

    # 並び替え設定（評価順なら"rating"）
    rankby = params[:sort] == "rating" ? "" : "prominence" # Googleは"prominence"がデフォルト
    order_by_rating = params[:sort] == "rating"

    if params[:lat].present? && params[:lng].present?
      lat = params[:lat]
      lng = params[:lng]
      radius = params[:radius].presence || 1000
      encoded_keyword = URI.encode_www_form_component(keyword)

      # note: rankby=distanceの場合、radiusを指定できない
      query = URI("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{lat},#{lng}&radius=#{radius}&keyword=#{encoded_keyword}&language=ja&key=#{api_key}")

    elsif params[:location].present?
      # 地名からの検索
      query_string = "#{params[:location]} #{keyword}"
      encoded_query = URI.encode_www_form_component(query_string)
      query = URI("https://maps.googleapis.com/maps/api/place/textsearch/json?query=#{encoded_query}&language=ja&region=jp&key=#{api_key}")

    elsif keyword.present?
      # キーワードだけの検索（地域なし）
      encoded_keyword = URI.encode_www_form_component(keyword)
      query = URI("https://maps.googleapis.com/maps/api/place/textsearch/json?query=#{encoded_keyword}&language=ja&region=jp&key=#{api_key}")

    else
      @results = []
      flash.now[:alert] = "検索条件を入力してください"
      render :index
      return
    end

    response = Net::HTTP.get(query)
    json = JSON.parse(response)

    if json["status"] == "OK"
      @results = json.dig("results") || []
      @results = @results.sort_by { |r| -r["rating"].to_f } if order_by_rating
      @results = @results.first(20)
    else
      @results = []
      flash.now[:alert] = "検索エラー: #{json['status']}"
    end

    render :index
  end

  def show # 各店舗の詳細ページ
    place_id = params[:place_id]
    session[:last_place_id] = place_id
    api_key = ENV["PLACES_API_KEY"]

    uri = URI("https://maps.googleapis.com/maps/api/place/details/json?place_id=#{place_id}&language=ja&key=#{api_key}")
    response = Net::HTTP.get(uri)
    json = JSON.parse(response)

    if json["status"] == "OK"
      @google_store = json["result"]
    else
      redirect_to root_path, alert: "店舗情報が取得できませんでした（#{json['status']}）"
      return
    end

    @store = Store.find_or_initialize_by(place_id: place_id)
    @store.name = @google_store["name"]
    @store.address = @google_store["formatted_address"]
    @store.save!

    @reviews = @store.reviews.includes(:user).order(created_at: :desc)
    @review = Review.new  # 口コミレビュー新規投稿
  end
end
