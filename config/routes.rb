OmniApp::Application.routes.draw do

  match '/users',      to: 'users#updateSurvey',        via: 'post'

  match '/users/updateGenre', to: 'users#updateGenre', via: 'post'

  match '/users/updateInfluence', to: 'users#updateInfluence', via: 'post'

  match '/users/addMedia', to: 'users#addMedia', via: 'post'


  resources :users

  # asks the router to match the request to the edit action of the users' controller
  get     'edit' => 'users#edit'
  post "users/matchChoice"
  get 'view_matches' => 'users#view_matches'
  get 'findMatch' => 'users#findMatch'


=begin
  get "users/new"             # Currently empty; exists only to pass users/new test


  get "/users" => "users#index"
  get "/users/:id" => "users#show"
  get "/users/new" => "users#new"
  post "/users" => "users#create"  # usually a submitted form
  get "/users/:id/edit" => "users#edit"
  put "/users/:id" => "users#update" # usually a submitted form
  delete "/users/:id" => "users#destroy"
=end



  root               'home#home'
  get     'about'    => 'home#about'
  get     'profile'  => 'users#show'
  get     'matching' => 'users#findMatch'
  get     'testmatching' => 'users#testFindMatch', :as => :testFindMatch

  get     'users/:id/matches'  => 'users#showMatches', :as => :user_matches
  get     "users/:id/messagesList" =>  'users#showMsgList', :as => :messages_list
  get     'users/:id/messages'  => 'users#showMatchMsgs', :as => :user_match_msg
  get     'users/:ids/groupsMessages' =>  'users#showGroupMsgs', :as => :group_msgs
  post    "users/:id/createChat" => 'users#createChat', :as => :create_chat
  post    "users/:ids/createGroupChat" => 'users#createGroupChat', :as => :create_group_chat


  
  #get 'home/profile'          # Currently empty; exists only to pass home/profile test
                               # change to users/profile?


  get 'auth/:provider/callback', to: "sessions#create"

  delete 'sign_out', to: "sessions#destroy", as: 'sign_out'


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
