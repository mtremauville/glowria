# config/routes.rb
Rails.application.routes.draw do
  devise_for :users

  root "dashboard#index"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :products, only: [:index, :show, :new, :create] do
    collection { get :lookup }
  end

  resources :user_products, only: [:create, :destroy]

  resources :routines, only: [:index] do
    member { post :generate }
  end

  resources :conflicts, only: [:index]
  resources :chat_messages, only: [:index, :create]

  get "/onboarding", to: "onboarding#show"
  patch "/onboarding", to: "onboarding#update"
end
