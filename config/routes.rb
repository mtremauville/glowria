Rails.application.routes.draw do
  get "onboarding/show"
  get "onboarding/update"
  get "chat_messages/index"
  get "chat_messages/create"
  get "conflicts/index"
  get "routines/index"
  get "routines/show"
  get "routines/generate"
  get "user_products/create"
  get "user_products/destroy"
  get "products/index"
  get "products/show"
  get "products/new"
  get "products/create"
  get "dashboard/index"
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  devise_for :users

  root "dashboard#index"

  resources :products, only: [:index, :show, :new, :create]
  resources :user_products, only: [:create, :destroy]
  resources :routines, only: [:index, :show] do
    member { post :generate }
  end
  resources :conflicts, only: [:index]
  resources :chat_messages, only: [:index, :create]

  get "/onboarding", to: "onboarding#show"
  patch "/onboarding", to: "onboarding#update"
end
