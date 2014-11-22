ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  map.login 'login', :controller => 'sessions', :action => 'new'
  map.logout 'logout', :controller => 'sessions', :action => 'destroy'
  map.signup 'signup', :controller => 'accounts', :action => 'new'

  map.resources :sessions

  # Backend admin area
  map.namespace(:backend, :conditions => { :subdomain => 'admin' }) do |backend|
    backend.resource :dashboard
  end
  
  map.backend_root '', :controller => 'backend/dashboards', :action => 'show', :conditions => { :subdomain => 'admin' }


  # Guild admin area
  map.namespace :admin do |admin|
    admin.resource :dashboard
    admin.resources :events, :member => { :update_attendance => :put }, :collection => { :char_attendance_row => :post } do |events|
      events.resource :plan, :member => { :stats => :get }
    end
    admin.resources :plans, :only => [:index]
    admin.resources :balances, :member => { :filter => :post }
    admin.resources :roster, :only => [:index], :collection => { :update_all => :put }, :member => { :gkick => :put, :create_sms => :get, :send_sms => :put }
    admin.resources :settings, :only => [:index], :collection => { :update_all => :put }
  end
  
  # Regular guild area
  map.resource :guild, :collection => { :_armory_sync_status => :get, :_acknowledge_armory_sync_complete => :put }
  map.resources(:events, :only => [:index, :show], :collection => { :attendance => :get }) do |events|
    events.resource :signup, :only => [:create, :update, :destroy], :member => { :toggle => :put }
    events.resource :plan, :only => [:show]
  end
  map.resources :balances, :member => { :filter => :post }
  map.balance_history 'balances/:balance_id/history/:char_id', :controller => 'balances', :action => 'history', :conditions => { :method => :get }
  map.resources :roster, :collection => { :filter => :post }, :only => [:index, :show]

  # Guild API area
  map.connect '/api/:controller/:action/:id', :api => true, :conditions => { :subdomain => /.+/ }

  # Accounts
  map.resource(:account, :member => { :success => :get, :confirm => :get, :resend_confirmation => :put, :verify => :get, :verify_manual => :put, :forgot => :get, :remind => :post, :new_password => :get, :reset_password => :put }) do |account|
    account.resources :characters, :member => { :join => :post, :find_guild => [:get, :post], :withdraw => :get, :armory_update => :get, :promote => :get }, :only => [:index, :new, :create, :destroy, :update]
  end
  
  map.connect '/account/new_password/:reset_code', :controller => 'accounts', :action => 'new_password'


  # Public API area
  map.connect '/api/wow/realms.:format', :controller => '/api/wow', :action => 'realms', :conditions => { :subdomain => nil }
  map.connect '/api/wow/realms/:region.:format', :controller => '/api/wow', :action => 'realms', :conditions => { :subdomain => nil }
  map.connect '/api/wow/realms/:region/:subregion.:format', :controller => '/api/wow', :action => 'realms', :conditions => { :subdomain => nil }
  map.connect '/api/wow/realms/:region/:subregion/:realm_type.:format', :controller => '/api/wow', :action => 'realms', :conditions => { :subdomain => nil }

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.guild_root '', :controller => 'guilds', :action => 'show', :conditions => { :subdomain => /.+/ }
  map.root :controller => "home"
  
  map.contact 'contact', :controller => 'home', :action => 'contact'
  map.security 'security', :controller => 'home', :action => 'security'
  map.tour 'tour', :controller => 'home', :action => 'tour'
  map.pricing 'pricing', :controller => 'home', :action => 'pricing'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
