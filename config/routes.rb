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
    resources :users, only: [ :show ]
  end

  resources :stores, only: %i[index show], param: :place_id do
    collection do
      get :search
    end
  end

  resources :reviews

  get "up" => "rails/health#show", as: :rails_health_check

  root "tops#index"
end
