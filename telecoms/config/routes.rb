Rails.application.routes.draw do
 
   get '/dropbox_authorize' => 'sessions#authorize', as: 'dropbox_authorize'
  get '/dropbox_unauthorize' => 'sessions#unauthorize', as: 'dropbox_unauthorize'
  get '/dropbox_path_change' => 'users#dropbox_path_change', as: 'dropbox_path_change'
  get '/dropbox_callback' => 'sessions#dropbox_callback', as: 'dropbox_callback'
  get '/dropbox_download' => 'users#dropbox_download', as: 'dropbox_download'
  post '/dropbox_upload' => 'users#upload', as: 'upload'
  post '/dropbox_search' => 'users#search', as: 'search'
  
  root to: 'static_pages#home'
  get 'static_pages/home'
  get 'signup' => 'users#new',as:  :signup
  get 'static_pages/help'
  get    'login'   => 'sessions#new'
  post   'login'   => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'
   
  resources :users do
   resources :dropbox_files 
    resources :share_files
  end
  
 # resources :dropbox_files    ,      only: [:create, :destroy]
  #resources :share_files,       only: [:create, :destroy]
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
