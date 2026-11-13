Rails.application.routes.draw do
  get "up", to: "health#show"
  resource :session, only: [ :new, :create, :destroy ]
  resource :appearance, only: :show
  resources :plants, only: [ :index, :show, :new, :create ]
  root "plants#index"
end
