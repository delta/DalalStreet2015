Rails.application.routes.draw do
  
  devise_for :users

  get 'index/index'

 #get 'dalal_dashboard/index'  remove it later only for development purpose

  get '/dalal_dashboard/:id' => 'dalal_dashboard#show' 
  get '/dalal_dashboard/:id/stock' => 'dalal_dashboard#stock'
  post '/dalal_dashboard/:id/stock_ajax_handler' => 'dalal_dashboard#stock_ajax_handler'
  get '/dalal_dashboard/:id/events' => 'dalal_dashboard#market_events'
  get '/dalal_dashboard/:id/buy_sell_page' => 'dalal_dashboard#buy_sell_page'
  get '/dalal_dashboard/:id/buy_sell_stock'=> 'dalal_dashboard#buy_sell_stock'
  post '/dalal_dashboard/:id/buy_sell_stock'=> 'dalal_dashboard#buy_sell_stock'
  get '/dalal_dashboard/:id/bank_mortgage'=> 'dalal_dashboard#bank_mortgage'
  get '/dalal_dashboard/:id/bank_mortgage_stock'=> 'dalal_dashboard#bank_mortgage_stock'
  post '/dalal_dashboard/:id/bank_mortgage_stock'=> 'dalal_dashboard#bank_mortgage_stock'
  get '/admin/index' => 'admin#index' ###controller not yet created


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
