Rails.application.routes.draw do
  resource :account_name, only: [ :edit, :update ]

  resources :users, only: [ :edit, :update ] do
      get   :confirm_destroy, on: :collection
      get   :send_email,      on: :collection
      post  :confirm_destroy, on: :collection
      match "destroy_account/:token", to: "users#destroy_account",
                                      via: [ :get, :delete ],
                                      on: :collection,
                                      as: :destroy_account
  end

  resources :daily_notes,     only: [ :index, :new, :create, :edit, :update, :destroy ]
  resources :moon_notes,      only: [ :index, :new, :create, :edit, :update, :destroy ]

  resource  :registration,    only: [ :new, :create ]
  resource  :session,         only: [ :new, :create, :destroy ]

  resource  :email,           only: [ :edit, :update ]

  resource  :moon_sign,       only: [ :new, :create, :show ]

  resource  :analysis,        only: [ :show ], path: "insights", controller: "analysis" do
      post  :weekly_insight,  on: :collection
  end

  resources :password_resets, only: [ :new, :create ] do
    collection do
      get :sent
      get :edit
    end
  end

  patch "password_resets", to: "password_resets#update"

  namespace :api do
    resources :weekly_insights, only: [ :create ] do
      member do
        get :fragment
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root to: "home#index"
  get  "home/index"
  get  "line_login_api/login",    to: "line_login_api#login"
  get  "line_login_api/callback", to: "line_login_api#callback"
  post "line_login_api/callback", to: "line_login_api#callback"
  get  "dashboard",               to: "dashboard#index",          as: :dashboard

  get  "/mypage",                 to: "users#mypage",             as: :mypage

  get  "calendar",                to: "calendar#show",            as: :calendar

  get "/pages/*id" =>             "high_voltage/pages#show",      as: :page

  get "/moon_sign/:sign",         to: "moon_signs#show"

  if Rails.env.test?
    require "rack_session_access/capybara"
    mount RackSessionAccess::Middleware.new(Rails.application),   at: "/rack_session"
  end

  # letter_openerのルーティング
  mount LetterOpenerWeb::Engine,                                  at: "/letter_opener" if Rails.env.development?
end
