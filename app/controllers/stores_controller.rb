require "net/http"
require "uri"
require "json"

class StoresController < ApplicationController
  def index
    # 検索フォーム表示
  end

  def search
    api_key = ENV["PLACES_API_KEY"]

    @location = params[:location]
    @lat      = params[:lat]
    @lng      = params[:lng]
    @radius   = params[:radius] || 1000
    @sort     = params[:sort]
    @keyword  = params[:keyword].to_s.strip

    order_by_rating = @sort == "rating"

    keyword_for_api = @keyword.present? ? "うどん #{@keyword}" : "うどん"
    encoded_keyword = URI.encode_www_form_component(keyword_for_api)

    if @lat.present? && @lng.present?
      # 現在地あり → Nearby Search
      query = URI("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{@lat},#{@lng}&radius=#{@radius}&keyword=#{encoded_keyword}&language=ja&key=#{api_key}")

    elsif @location.present? || @keyword.present?
      # 地名 or キーワードあり → Text Search
      encoded_query = URI.encode_www_form_component([ @location, keyword_for_api ].compact.join(" "))
      query = URI("https://maps.googleapis.com/maps/api/place/textsearch/json?query=#{encoded_query}&language=ja&region=jp&key=#{api_key}")

    else
      # 何も入力されていない
      flash.now[:alert] = "検索条件を入力してください。"
      @results = []
      render :index and return
    end

    response = Net::HTTP.get(query)
    json = JSON.parse(response)

    if json["status"] == "OK"
      @results = json["results"] || []
      @results = @results.sort_by { |r| -r["rating"].to_f } if order_by_rating
      @results = @results.first(20)
    else
      @results = []
    end

    render :index
  end

  def show
    place_id = params[:place_id]
    session[:last_place_id] = place_id
    api_key = ENV["PLACES_API_KEY"]

    @store = Store.find_or_initialize_by(place_id: place_id)

    if place_id.start_with?("test-place")
      @google_store = nil
    else
      uri = URI("https://maps.googleapis.com/maps/api/place/details/json?place_id=#{place_id}&language=ja&key=#{api_key}")
      response = Net::HTTP.get(uri)
      json = JSON.parse(response)

      if json["status"] == "OK"
        @google_store = json["result"]
        @store.name    ||= @google_store["name"]
        @store.address ||= @google_store["formatted_address"]
        @store.save!
      else
        @google_store = nil
        flash.now[:alert] = "Googleから店舗情報を取得できませんでした。（#{json['status']}）"
      end
    end

    @reviews = @store.reviews.includes(:user).order(created_at: :desc)
  end
end
