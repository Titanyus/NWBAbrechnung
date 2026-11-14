Rails.application.routes.draw do
  get "up", to: "health#show"
  resource :session, only: [ :new, :create, :destroy ]
  resource :plant_selection, only: :update
  resource :appearance, only: :show
  resources :plants, only: [ :index, :show, :new, :create, :edit, :update ] do
    resources :customers, except: :destroy do
      post :link, on: :collection
    end
    resources :route_sections, except: [ :destroy, :show ]
    resources :connections, except: :destroy
    resources :supply_contracts, except: :destroy
    resources :heat_meters, except: :destroy do
      get :replacement, on: :member
      post :exchange, on: :member
      post :retire, on: :member
      resources :meter_readings, only: [ :new, :create ]
    end
  end
  root "plants#index"
end
