require 'resque/server'
Rails.application.routes.draw do
   
  mount Resque::Server.new, at: "/resque"

  devise_for :users

  get 'index/index'

 #get 'dalal_dashboard/index'  remove it later only for development purpose

  get '/dalal_dashboard/:id' => 'dalal_dashboard#show'
  get '/dalal_dashboard/:id/index' => 'dalal_dashboard#show'
  get '/dalal_dashboard/:id/stock' => 'dalal_dashboard#stock'
  post '/dalal_dashboard/:id/stock_ajax_handler' => 'dalal_dashboard#stock_ajax_handler'
  get '/dalal_dashboard/:id/market_events' => 'dalal_dashboard#market_events'
  get '/dalal_dashboard/:id/buy_sell_page' => 'dalal_dashboard#buy_sell_page'
  post '/dalal_dashboard/:id/buy_sell_stock'=> 'dalal_dashboard#buy_sell_stock'
  get '/dalal_dashboard/:id/bank_mortgage'=> 'dalal_dashboard#bank_mortgage'
#  get '/dalal_dashboard/:id/bank_mortgage_stock'=> 'dalal_dashboard#bank_mortgage_stock'
  post '/dalal_dashboard/:id/bank_mortgage_stock'=> 'dalal_dashboard#bank_mortgage_stock'
  post '/dalal_dashboard/:id/bank_return_stock'=> 'dalal_dashboard#bank_return_stock'
  get '/dalal_dashboard/:id/company' => 'dalal_dashboard#company'
  get '/dalal_dashboard/:id/buy_sell_history' => 'dalal_dashboard#buy_sell_history'
  get '/dalal_dashboard/:id/leaderboard' => 'dalal_dashboard#leaderboard'

  get '/admin/index' => 'admin#index' ###controller not yet created
  get '/admin/market_events' => 'admin#market_events'
  #post '/admin/market_events' => 'admin#market_events'

  get '/admin/company_events' => 'admin#company_events'


  get '/admin/bank_rates' => 'admin#bank_rates'
  

  resources :users
  get '/admin/user_details' => 'admin#user_details'   
  post '/admin/user_details' => 'admin#user_details'  
  patch '/admin/stockmanipulator' => 'admin#stockmanipulator' ###not defined yet  
  get '/admin/stockmanipulator' => 'admin#stockmanipulator'  
  get '/admin/bulkupdate' => 'admin#bulkupdate'  


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'index#index'

  # Example of regular route:
  #   get 'prodxucts/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
