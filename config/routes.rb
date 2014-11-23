Srsguild::Application.routes.draw do
  match 'login' => 'sessions#new', :as => :login
  match 'logout' => 'sessions#destroy', :as => :logout
  match 'signup' => 'accounts#new', :as => :signup

  resources :sessions
  namespace :backend, :conditions => { :subdomain => 'admin' } do
    resource :dashboard

    match '' => 'backend/dashboards#show', :as => :backend_root, :via => :get
  end

  namespace :admin do
    resource :dashboard
    resources :events do
      collection do
        post :char_attendance_row
      end

      member do
        put :update_attendance
      end

      resource :plan do
        member do
          get :stats
        end
      end
    end

    resources :plans, :only => [:index]
    resources :balances do
      member do
        post :filter
      end
    end

    resources :roster, :only => [:index] do
      collection do
        put :update_all
      end

      member do
        put :gkick
        get :create_sms
        put :send_sms
      end
    end

    resources :settings, :only => [:index] do
      collection do
        put :update_all
      end
    end
  end

  resource :guild do
    collection do
      get :_armory_sync_status
      put :_acknowledge_armory_sync_complete
    end
  end

  resources :events, :only => [:index, :show] do
    collection do
      get :attendance
    end

    resource :signup, :only => [:create, :update, :destroy] do
      member do
        put :toggle
      end
    end

    resource :plan, :only => [:show]
  end

  resources :balances do
    member do
      post :filter
    end

    match 'balances/:balance_id/history/:char_id' => 'balances#history', :as => :balance_history, :via => :get
  end

  resources :roster, :only => [:index, :show] do
    collection do
      post :filter
    end
  end

  resource :account do
    member do
      get :success
      get :confirm
      put :resend_confirmation
      get :verify
      put :verify_manual
      get :forgot
      post :remind
      get :new_password
      put :reset_password
    end

    resources :characters, :only => [:index, :new, :create, :destroy, :update] do
      member do
        post :join
        get :find_guild
        post :find_guild
        get :withdraw
        get :armory_update
        get :promote
      end
    end
  end

  match '/account/new_password/:reset_code' => 'accounts#new_password'


  #match '/api/:controller/:action/:id' => '#index', :api => true
  #match '/api/wow/realms.:format' => '/api/wow#realms', :via => :get
  #match '/api/wow/realms/:region.:format' => '/api/wow#realms', :via => :get
  #match '/api/wow/realms/:region/:subregion.:format' => '/api/wow#realms', :via => :get
  #match '/api/wow/realms/:region/:subregion/:realm_type.:format' => '/api/wow#realms', :via => :get

  #match '' => 'guilds#show', :as => :guild_root, :via =>

  match '/' => 'home#index', as: :root
  match 'contact' => 'home#contact', :as => :contact
  match 'security' => 'home#security', :as => :security
  match 'tour' => 'home#tour', :as => :tour
  match 'pricing' => 'home#pricing', :as => :pricing

  match '/:controller(/:action(/:id))'
end
