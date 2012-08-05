Silo::Application.routes.draw do
  root to: 'experts#index'

  get    'login' => 'login#welcome'
  post   'login' => 'login#login'
  delete 'login' => 'login#logout'

  get 'profile' => 'users#profile'
  put 'profile' => 'users#update_profile'

  get 'expert/:id' => 'experts#show'

  resources :users, except: [:show]
  resources :experts
  resources :partners
  resources :references
end
