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

  namespace :users do
    resource :profile, only: %i[show edit update]
  end

  resources :stores, only: [ :index, :show ] do
    collection do
      get :search
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "tops#index"
end
