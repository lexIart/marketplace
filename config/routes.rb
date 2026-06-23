Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # all routes inside will have prefix /seller/ in URL and will look up for controllers in controllers/seller/
  namespace :seller do
    # generate 7 RESTful routes for products; /seller/products/, controller - Seller:ProductsController
    resources :products do
      post :generate_variants, on: :member
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
