Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth', controllers: {
    registrations:  'registrations',
    sessions: 'sessions'
  }

  get '/subscription_list', to: 'contributions#index'
  post '/create_monthly_subscription', to: 'contributions#create'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
