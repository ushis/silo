Silo::Application.routes.draw do
  root to: 'experts#index'

  # Login
  get    'login' => 'login#welcome'
  post   'login' => 'login#login'
  delete 'login' => 'login#logout'

  # Profile
  get 'profile' => 'profile#edit'
  put 'profile' => 'profile#update'

  # Users
  resources :users, except: [:show]

  # Experts
  get 'experts(/page/:page)' => 'experts#index', as: :experts

  resources :experts, except: [:index] do
    resources :cvs,         only: [:show, :create, :destroy]
    resources :attachments, only: [:show, :create, :destroy]
    resources :contacts,    only: [:create, :destroy]
    resources :addresses,   only: [:create, :destroy]

    get :documents, on: :member
  end

  # Partners
  get 'partners(/page/:page)' => 'partners#index', as: :partners

  resources :partners, except: [:index] do
    resources :attachments, only: [:show, :create, :destroy]
    resources :employees,   only: [:index, :create, :update, :destroy]

    get :documents, on: :member
  end

  resources :employees, only: [] do
    resources :contacts, only: [:create, :destroy]
  end

  # Projects
  get 'projects(/page/:page)'   => 'projects#index',     as: :projects

  resources :projects, only: [:new, :create] do
    resources :attachments,     only: [:show, :create, :destroy]
    resources :project_members, only: [:index, :create, :destroy], as: :members
    resources :partners,        only: [:index, :create, :destroy], controller: :project_partners

    get :documents, on: :member
  end

  get    'projects/:id/edit/:lang' => 'projects#edit',    as: :edit_project
  get    'projects/:id(/:lang)'    => 'projects#show',    as: :project
  put    'projects/:id/:lang'      => 'projects#update'
  delete 'projects/:id'            => 'projects#destroy', as: :destroy_project

  # Lists
  get 'lists(/page/:page)' => 'lists#index', as: :lists

  resources :lists, only: [:create, :update, :destroy] do
    resources :list_items, only: [:destroy]

    put :copy,    on: :member
    put :concat,  on: :member

    [:experts, :partners, :projects, :employees].each do |item_type|
      resources item_type, only: [], controller: :list_items do
        get :index, action: item_type, on: :collection
      end
    end
  end

  # Ajax
  namespace :ajax do
    resources :help,    only: :show
    resources :helpers, only: :show
    resources :tags,    only: :show

    resources :experts, only: [] do
      resources :addresses,   only: :new
      resources :contacts,    only: :new
      resources :attachments, only: :new
      resources :cvs,         only: :new
    end

    resources :partners, only: [] do
      resources :attachments, only: :new
      resources :employees,   only: [:new, :edit]
    end

    resources :employees, only: [] do
      resources :contacts, only: :new
    end

    resources :projects, only: [] do
      resources :attachments,     only: :new

      resources :project_members, only: [:index, :update], as: :members do
        collection do
          get 'new/:expert_id' => 'project_members#new', as: :new
          get :search
        end
      end

      resources :partners, only: [:index], controller: :project_partners do
        get :search, on: :collection
      end
    end

    [:areas, :languages].each do |controller|
      resources controller, only: :index
    end

    resources :lists, except: [:create, :update, :destroy] do
      resources :list_items, only: [:update]

      member do
        put :open
        get :copy
        get :import
      end

      [:experts, :partners, :projects].each do |resource|
        resources resource, only: [], controller: :list_items do
          collection do
            get    :print,   action: "print_#{resource}"
            post   :create,  action: "create_#{resource}"
            delete :destroy, action: "destroy_#{resource}"
          end
        end
      end
    end
  end
end
