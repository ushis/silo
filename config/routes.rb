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
    get :select, on: :collection
  end

  # Experts
  get 'experts(/page/:page)' => 'experts#index', as: :experts

  resources :experts, except: [:index] do
    resources :cvs,         only: [:show, :create, :destroy]
    resources :attachments, only: [:show, :create, :destroy]
    resources :contacts,    only: [:create, :destroy]
    resources :addresses,   only: [:create, :destroy]

    get 'search(/page/:page)' => 'experts#search', as: :search, on: :collection
    get :documents, on: :member
  end

  # Partners
  get 'partners(/page/:page)' => 'partners#index', as: :partners

  resources :partners, except: [:index] do
    resources :attachments, only: [:show, :create, :destroy]
    resources :contacts,    only: [:create, :destroy]
    resources :employees

    get 'search(/page/:page)' => 'partners#search', as: :search, on: :collection
    get :documents, on: :member
  end

  # References
  resources :references

  # Lists
  get 'lists(/page/:page)' => 'lists#index', as: :lists

  resources :lists, except: [:index, :show] do
    collection do
      get  'search(/page/:page)' => 'lists#search', as: :search
      get  :select
      get  :current
      post :add
      post :remove
    end

    member do
      put :open
      get :copy
      put :copy, action: :duplicate
    end

    [:experts, :partners].each do |resource|
      resources resource, only: [], controller: :lists do
        get    :index,   action: resource, on: :collection
        delete :destroy, action: :remove,  on: :member
      end
    end
  end

  # Help
  get 'help/:section' => 'help#show', as: :help

  # Areas, Languages, Businesses
  [:areas, :languages, :businesses].each do |controller|
    get "#{controller}/select" => "#{controller}#select"
  end
end
