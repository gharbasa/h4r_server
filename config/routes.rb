#Rails.application.routes.draw do
H4R::Application.routes.draw do
  #get 'test/index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'
  #get 'index' => "home#index"

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  namespace :api_v1, :path => 'api/1' do
    resources :test, :only => [:index, :show, :create, :update, :destroy] do
      #collection do
      #  put :reorder
      #end
    end
    
    resources :users, :only => [:index, :show, :create, :update, :destroy] do
      collection do
        #put :reorder
        get :search
      end
      member do
        put :verified #this is only for admin access
      end
      resources :notifications, :only => [:index] do
        member do
          post :inactivate
        end
      end
      resources :houses, :only => [:index] do
         resources :housenotes, :only => [:index, :show, :create, :update, :destroy]
      end
      resources :user_house_links, :only => [:index]
      resources :user_house_contracts, :only => [:index]
      #member do |m|
        
      #end
    end
        
    resources :notifications, :only => [:index, :show, :create, :update, :destroy] do
      member do
        post :inactivate
      end
    end
    
    resources :notification_types, :only => [:index, :show, :create, :update, :destroy] do
      resources :notifications, :only => [:index]
    end
    
    resources :usersession, :only => [:index, :show, :create, :destroy] do
      collection do
        #put :reorder
        get :all
      end
    end
    
    resources :houses, :only => [:index, :show, :create, :update, :destroy] do
      collection do
        #put :reorder
        get :search
      end
      member do
        put :verified
        post :inactivate
        post :activate
        #get :notes, :only => [:notes]
        #post :create_note, :only => [:create_note]
      end
      resources :user_house_links, :only => [:index]
      resources :house_pics, :only => [:index]
      resources :user_house_contracts, :only => [:index]
      resources :housenotes, :path => 'notes', :only => [:index, :show, :create, :update, :destroy]
    end
    
    resources :user_house_links, :only => [:index, :show, :create, :update, :destroy] do
      #destroy will delete the record, but not mark as inactive. After owner association is deleted
      #admin can only make someone as house owner.
    end
    
    resources :user_house_contracts, :only => [:index, :show, :create, :update, :destroy] do
      
    end
    
    resources :house_pics, :only => [:index, :show, :create, :update, :destroy] do
      #destroy will delete the record, but not mark as inactive. After owner association is deleted
      #admin can only make someone as house owner.
    end
    
    resources :communities, :only => [:index, :show, :create, :update, :destroy] do
      collection do
        #put :reorder
        get :search
      end
      member do
        put :verified
      end
      resources :community_pics, :only => [:index]
    end
    
    resources :community_pics, :only => [:index, :show, :create, :update, :destroy] do
      #destroy will delete the record, but not mark as inactive. After owner association is deleted
      #admin can only make someone as house owner.
    end

  end
  #root 'welcome#index'
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
