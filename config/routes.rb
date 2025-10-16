Rails.application.routes.draw do
  get 'images/new'
  get 'images/create'
  get 'chats/index'
  get 'chats/create'
  get 'profiles/show'
  get 'profiles/edit'
  get 'profiles/update'
  devise_for :users, controllers: {
    sessions: 'user/sessions',
    registrations: 'user/registrations'
  }

  root "home#index"

  resources :posts, only: %i[index new create destroy edit update show] do
    member do
      get 'like'
      get 'repost'
    end
  end

  resource :profile, only: [:show, :edit, :update]
  resources :chats, only: [:index, :create] do
    collection do
      post :ask
    end
  end
  resources :images, only: [:index, :new, :create, :destroy] do
    collection do
      get :new_variant
      post :variants
      get :test_api
      get :debug_vision
      post :debug_vision
    end
  end

  resources :conversations, only: [:index, :show, :create, :new] do
    resources :messages, only: [:create, :destroy]
  end

  resources :messages, only: [:show]

  # User status routes
  resources :users, only: [] do
    member do
      get :status
    end
    
    collection do
      post :update_status
    end
  end
  
  # User status with Turbo Streams
  resources :user_statuses, only: [] do
    collection do
      post :publish
    end
  end
  
  # API endpoints
  namespace :api do
    get "/presigned_url/:message_id", to: "presigned_urls#show", as: :presigned_url
    resources :users, only: [] do
      member do
        get :avatar
      end
    end
    resources :images, only: [:index, :create, :destroy]
    
    # Explicitly define profile routes
    get '/profile', to: 'profiles#show'
    put '/profile', to: 'profiles#update'
    patch '/profile', to: 'profiles#update'
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "/profiles", to: "profiles#index", as: :profiles
end
