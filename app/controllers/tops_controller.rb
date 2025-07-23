class TopsController < ApplicationController
  def index
    api_key = ENV["PLACES_API_KEY"]
    query = URI.encode_www_form_component("東京 うどん")
    url = URI("https://maps.googleapis.com/maps/api/place/textsearch/json?query=#{query}&language=ja&region=jp&key=#{api_key}")

    response = Net::HTTP.get(url)
    json = JSON.parse(response)

    # レート4.0以上のうどん屋をランダムに最大6件表示
    all_results = json["results"] || []
    high_rated = all_results.select { |store| store["rating"].to_f >= 4.0 }
    @results = high_rated.sample(4)

    # @reviews = Review.order(created_at: :desc).limit(5) # 最新5件の口コミを表示
  end

  def detail
  end

  def tos
  end

  def privacy
  end
end
