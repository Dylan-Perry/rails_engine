Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      get '/merchants/find_all', to: 'merchants/search#find_all'
      resources :merchants, only: [:index, :show] do
        resources :items, only: [:index], module: :merchants # module block to scope the items controller under merchants 
      end 
      
      get '/items/find', to: 'items/search#find'
      resources :items, only: [:index, :show, :create, :update, :destroy] do
        resources :merchant, only: [:index], module: :items
      end
    end
  end
end
