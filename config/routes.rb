Rails.application.routes.draw do
  root to: 'products#new'

  resources :products, only: %i[new create] do
    resources :reviews, only: [:index]
  end

  get '/search', to: 'products#search'
end
