Silo::Application.routes.draw do
  root to: 'experts#index'

  # Login
  get    'login' => 'login#welcome'
  post   'login' => 'login#login'
  delete 'login' => 'login#logout'

  # Users
  get 'profile' => 'users#profile'
  put 'profile' => 'users#update_profile'

  resources :users, except: [:show] do
    collection do
      get :select
    end
  end

  # Experts
  get 'experts(/page/:page)' => 'experts#index', as: :experts

  resources :experts, except: [:index] do
    resources :cvs,         only: [:show, :create, :destroy]
    resources :attachments, only: [:show, :create, :destroy], controller: 'attachments/experts'
    resources :contacts,    only: [:create, :destroy],        controller: 'contacts/experts'
    resources :addresses,   only: [:create, :destroy],        controller: 'addresses/experts'

    collection do
      get 'search(/page/:page)' => 'experts#search', as: :search
    end

    member do
      get :documents
    end
  end

  # Partners
  get 'partners(/page/:page)' => 'partners#index', as: :partners

  resources :partners, except: [:index] do
    collection do
      get 'search(/page/:page)' => 'partners#search', as: :search
    end

    member do
      get :documents
    end
  end

  # References
  resources :references

  # Lists
  resources :lists do
    collection do
      get :select
    end

    member do
      put :use
    end
  end

  # Help
  get 'help/:section' => 'help#show', as: :help

  # Areas, Languages, Businesses
  [:areas, :languages, :businesses].each do |controller|
    get "#{controller}/select" => "#{controller}#select"
  end
end
