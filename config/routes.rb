Rails.application.routes.draw do

  resources :products, only: %i[new create] do
    resources :reviews, only: [:index]
  end
end
