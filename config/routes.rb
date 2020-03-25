Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  
  devise_scope :user do
  delete 'sign_out', :to => 'devise/sessions#destroy', :as => :facebook_destroy_user_session
  end
  
  root 'static_pages#home'
  get "home", to: "home#index", as: "user_root"
  get  '/home',    to: 'static_pages#home'
  get  '/help',    to: 'static_pages#help'
  get  '/about',   to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'
  get  '/signup',  to: 'users#new'
  post '/signup',  to: 'users#create'
  get   '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :account_activations, only: [:edit]
  # GET	/account_activation/<token>/edit
  # ユーザーにメールで送ったこのURLをクリックしてもらうとeditアクションのみを反応させる
  resources :microposts,          only: [:create, :destroy]
  resources :relationships,       only: [:create, :destroy]
end
