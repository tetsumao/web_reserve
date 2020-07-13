Rails.application.routes.draw do
  root "web_reservations#status"
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }
  resources :items, only: [:index]
  resources :web_reservations, only: [:index, :show, :new, :create] do
    collection do
      get :status
    end
  end
  controller :api do
    post 'api/sign_in'
    delete 'api/sign_out'
    get 'api/master_updated_at'
    post 'api/upsert_items'
    get 'api/mng_reservation_id_updated_at'
    post 'api/upsert_mng_reservations'
    post 'api/destroy_mng_reservations'
    get 'api/web_reservation_ids'
    get 'api/web_reservation'
    post 'api/update_web_reservation'
  end
end
