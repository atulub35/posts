Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'user/sessions'
  }

  root "home#index"

  resources :posts, only: %i[index new create destroy edit update show] do
    member do
      get 'like'
      get 'repost'
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
