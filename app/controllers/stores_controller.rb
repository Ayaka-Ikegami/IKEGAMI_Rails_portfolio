class StoresController < ApplicationController
  require "net/http"
  require "uri"
  require "json"

  def index
    # 検索フォーム表示
  end

  def search
    keyword = params[:keyword]
    api_key = ENV["PLACES_API_KEY"]

    if keyword.present?
      query = "#{keyword} うどん"
      encoded_keyword = URI.encode_www_form_component(query)
      url = URI("https://maps.googleapis.com/maps/api/place/textsearch/json?query=#{encoded_keyword}&language=ja&region=jp&key=#{api_key}")

      response = Net::HTTP.get(url)
      json = JSON.parse(response)

      if json["status"] == "OK"
        @results = json["results"]
      else
        @results = []
        flash.now[:alert] = "検索エラー: #{json['status']}"
      end

    else
      @results = []
    end

    render :index
  end
end
