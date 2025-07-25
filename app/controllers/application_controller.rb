class ApplicationController < ActionController::Base
  before_action :store_user_location!, if: :storable_location?

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  def fetch_google_place_details(place_id)
    api_key = ENV["PLACES_API_KEY"]
    uri = URI("https://maps.googleapis.com/maps/api/place/details/json?place_id=#{place_id}&language=ja&key=#{api_key}")
    response = Net::HTTP.get(uri)
    json = JSON.parse(response)

  return json["result"] if json["status"] == "OK"

    nil
  end
end
