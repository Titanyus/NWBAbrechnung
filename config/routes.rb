Rails.application.routes.draw do
  get "up", to: "health#show"
  resource :session, only: [ :new, :create, :destroy ]
  resource :plant_selection, only: :update
  resource :appearance, only: :show
  resources :plants, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
    get :delete_confirmation, on: :member
    resources :customers, except: :destroy do
      post :link, on: :collection
    end
    resources :route_sections, except: [ :destroy, :show ]
    resources :connections, except: :destroy
    resources :supply_contracts, except: :destroy do
      get :draft_customers, on: :collection
      get :draft_connections, on: :collection
      get :draft_meter, on: :collection
    end
    resources :heat_meters, except: :destroy do
      get :replacement, on: :member
      post :exchange, on: :member
      post :retire, on: :member
      resources :meter_readings, only: [ :new, :create ]
    end
  end
  root "plants#index"
end
