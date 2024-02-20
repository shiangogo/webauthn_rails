Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'home#index'

  resource :registration, only: %i[new create] do
    post :callback
  end

  resource :session, only: %i[new create destroy] do
    post :callback
  end
end
