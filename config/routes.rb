Rails.application.routes.draw do
  resource :account_name, only: [ :edit, :update ]
  resources :users, only: [ :show, :edit, :update ]
  resources :daily_notes, only: [ :index, :new, :create, :edit, :update, :destroy ]
  resources :moon_notes, only: [ :index, :new, :create, :edit, :update, :destroy ]
  resource :session, only: [ :destroy ]
  resource :moon_sign, only: [ :new, :create, :show ]

  get "up" => "rails/health#show", as: :rails_health_check

  root to: "home#index"
  get "home/index"
  get "line_login_api/login", to: "line_login_api#login"
  get "line_login_api/callback", to: "line_login_api#callback"
  post "line_login_api/callback", to: "line_login_api#callback"
  get "dashboard", to: "dashboard#index", as: :dashboard

  get "mypage",   to: "users#mypage",   as: :account_name_edit
  get "settings", to: "users#settings"

  get "insights", to: "analysis#show", as: :analysis

  get "/pages/*id" => "high_voltage/pages#show", as: :page

  if Rails.env.test?
    require "rack_session_access/capybara"
    mount RackSessionAccess::Middleware.new(Rails.application), at: "/rack_session"
  end
end
