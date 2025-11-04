Rails.application.routes.draw do
  resource :account_name, only: [:edit, :update]
  resources :users, only: [:show, :edit, :update]

  get "up" => "rails/health#show", as: :rails_health_check

  root to: "home#index"
  get "home/index"
  get "line_login_api/login", to:"line_login_api#login"
  get "line_login_api/callback", to:"line_login_api#callback"
  post "line_login_api/callback", to:"line_login_api#callback"
  get "home/dashboard", to:"home#dashboard", as: :dashboard
  get "account_name/edit", to:"account_name#edit"
end
