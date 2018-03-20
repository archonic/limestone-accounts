require 'sidekiq/web'

Rails.application.routes.draw do
  # Administrate
  constraints CanAccessAdmin do
    namespace :admin do
      root controller: 'accounts', action: :index
      resources :accounts
      resources :users do
        post :impersonate, on: :member
      end
      get :stop_impersonating, to: :stop_impersonating, controller: 'users'
      resources :invoices
      resources :plans
      mount Flipper::UI.app(Flipper.instance) => '/flipper', as: 'flipper'
      mount Sidekiq::Web => '/sidekiq', as: 'sidekiq'
    end
  end

  mount StripeEvent::Engine, at: '/stripe/webhook'

  # Users are only added by invitation to accounts, but we still want users to manage their profile
  devise_for :users, path: '',
    skip: [:registrations],
    path_names: {
      sign_in: 'signin',
      sign_out: 'signout'
    },
    controllers: {
      sessions: 'users/sessions',
      invitations: 'users/invitations'
    } # registrations: 'users/registrations', passwords: "users/passwords"
  as :user do
    get 'users/edit', to: 'devise/registrations#edit', as: 'edit_user_registration'
    put 'users', to: 'devise/registrations#update', as: 'user_registration'
    post 'find_workspace', to: 'users/sessions#find_workspace', as: 'find_workspace'
  end

  unauthenticated :user do
    # Signed out (marketing) pages
    root to: 'pages#features'
    get 'pricing', to: 'pages#pricing'
    get 'about', to: 'pages#about'
    get 'cancelled', to: 'pages#cancelled'
  end

  # Account registration
  post 'account', to: 'accounts#create', as: 'accounts'
  get 'account/new', to: 'accounts#new'

  # Signed in pages
  authenticated :user do
    constraints Subdomain do
      root to: 'dashboard#show', as: 'dashboard'

      # Account management
      get 'account/edit', to: 'accounts#edit'
      get 'account', to: 'accounts#show', as: 'account_show'
      patch 'account', to: 'accounts#update', as: 'account_update'
      delete 'account/cancelled', to: 'accounts#destroy', as: 'account_destroy'
      get 'account/settings', to: 'accounts#edit', as: 'account_settings'

      # Members management
      # get 'members/new', to: 'invitations'
    end

    # Avatars
    patch 'avatars', to: 'avatars#update'
    delete 'avatar', to: 'avatars#destroy'

    # Subscription stuff
    get 'billing', to: 'subscriptions#show'
    get 'subscribe', to: 'subscriptions#new'
    patch 'subscriptions', to: 'subscriptions#update'
    get 'invoices', to: 'invoices#index'
    get 'invoices/:id', to: 'invoices#show', as: 'invoice'
  end

end
