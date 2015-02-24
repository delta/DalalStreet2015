require 'resque/server'
Rails.application.routes.draw do

  mount Resque::Server.new, at: "/resque"


######remove them later############################
  get 'users/sign_in' => redirect('/404.html')  
  devise_for :users, :controllers => { registrations: 'registrations' }
  

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

  get '/4Dm1N/index' => 'admin#index' ###controller not yet created
  post '/4Dm1N/index' => 'admin#index' ###controller not yet created

  get '/4Dm1N/market_events' => 'admin#market_events'
  #post '/4Dm1N/market_events' => 'admin#market_events'

  get '/4Dm1N/company_events' => 'admin#company_events'


  get '/4Dm1N/bank_rates' => 'admin#bank_rates'


  resources :users
  get '/4Dm1N/user_details' => 'admin#user_details'
  post '/4Dm1N/user_details' => 'admin#user_details'
  patch '/4Dm1N/stockmanipulator' => 'admin#stockmanipulator' ###not defined yet
  get '/4Dm1N/stockmanipulator' => 'admin#stockmanipulator'


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'index#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

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
  #     # Directs /4Dm1N/products/* to Admin::ProductsController
  #     # (app/controllers/4Dm1N/products_controller.rb)
  #     resources :products
  #   end
end
