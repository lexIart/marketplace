Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  namespace :seller do
    resources :products do
      post :generate_variants, on: :member
      post :add_simple_variant, on: :member
    end
  end

  namespace :catalog do
    resources :products, only: %i[index show]
  end

  root 'catalog/products#index'
end
