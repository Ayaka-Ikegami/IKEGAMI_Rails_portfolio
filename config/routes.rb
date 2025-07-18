Rails.application.routes.draw do
  get "tops/detail"
  get "tops/tos"
  get "tops/privacy"


  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions:      "users/sessions"
  }

  devise_scope :user do
    post "users/guest_sign_in", to: "users/sessions#guest_sign_in"
  end

  get "/stores", to: "stores#index"
  get "/stores/search", to: "stores#search", as: :search_stores

  get "up" => "rails/health#show", as: :rails_health_check

  root "tops#index"
end
