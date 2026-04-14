# config/routes.rb
Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  root "dashboard#index"

  get "up" => "rails/health#show", as: :rails_health_check

  # PWA
  get "manifest" => "pwa#manifest", as: :pwa_manifest, defaults: { format: :json }
  get "service-worker" => "pwa#service_worker", as: :pwa_service_worker
  get "offline" => "pwa#offline", as: :pwa_offline

  resources :products, only: [:index, :show, :new, :create] do
    collection do
      get  :lookup
      post :scan_composition
    end
  end

  resources :user_products, only: [:create, :destroy]

  resources :routines, only: [:index] do
    member { post :generate }
  end

  resources :conflicts, only: [:index]
  resources :chat_messages, only: [:index, :create]
  resources :conversations, only: [:show, :destroy]

  resource :profile, only: [:show, :update] do
    delete :avatar, on: :member
  end

  get "/onboarding", to: "onboarding#show"
  patch "/onboarding", to: "onboarding#update"

  
end
