Rails.application.routes.draw do
  resource :account_name, only: [ :edit, :update ]
  resources :users, only: [ :show, :edit, :update ]
  resources :daily_notes, only: [ :index, :new, :create, :edit, :update, :destroy ]

  get "up" => "rails/health#show", as: :rails_health_check

  root to: "home#index"
  get "home/index"
  get "line_login_api/login", to: "line_login_api#login"
  get "line_login_api/callback", to: "line_login_api#callback"
  post "line_login_api/callback", to: "line_login_api#callback"
  get "dashboard", to: "dashboard#index", as: :dashboard

  if Rails.env.test?
    require "rack_session_access/capybara"
  end
end
