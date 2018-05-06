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
        put :forgotPassword
      end
      member do
        put :verified #this is only for admin access
        put :promote2Admin  #this is only for admin access to promote user to admin role
        put :demoteFromAdmin  #this is only for admin access to promote user to admin role
        get :houseContracts  #Get all the house contracts associated with this user
        put :resetPassword
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
        get :list4Reports
      end
      member do
        put :verified
        put :inactivate
        put :activate
        put :makeitOpen
        put :makeitClosed
        #get :notes, :only => [:notes]
        #post :create_note, :only => [:create_note]
        get :contracts  #Get all the house contracts associated with this user
      end
      resources :user_house_links, :only => [:index]
      resources :house_pics, :only => [:index]
      resources :user_house_contracts, :only => [:index]
      resources :housenotes, :path => 'notes', :only => [:index, :show, :create, :update, :destroy]
    end
    
    resources :tickets, :only => [:index, :show, :create, :update, :destroy] do
      member do
        put :inactivate
        put :activate
      end
      resources :ticket_notes, :path => 'notes', :only => [:index, :show, :create, :update, :destroy]
    end
    
    resources :user_house_links, :only => [:index, :show, :create, :update, :destroy] do
      #destroy will delete the record, but not mark as inactive. After owner association is deleted
      #admin can only make someone as house owner.
      member do #input is like "houseId_userId_roleNumber" fetch list of all active and inactive contracts
        get :contracts
        #get :notes, :only => [:notes]
        #post :create_note, :only => [:create_note]
      end
    end
    
    resources :user_house_contracts, :only => [:index, :show, :create, :update, :destroy] do
        member do
           put :activate #this is only for admin access
           put :deactivate #this is only for admin access
           get :receivedPayments
        end
        resources :house_contract_notes, :path => 'notes', :only => [:index, :show, :create, :update, :destroy]
        resources :user_house_contract_pics, :path =>'pics', :only => [:index, :show, :create, :update, :destroy]
    end
    
    resources :house_pics, :only => [:index, :show, :create, :update, :destroy] do
      #destroy will delete the record, but not mark as inactive. After owner association is deleted
      #admin can only make someone as house owner.
    end
    
    resources :payments, :only => [:index, :show, :create, :update, :destroy] do
      #destroy will delete the record, but not mark as inactive. After owner association is deleted
      #admin can only make someone as house owner.
      collection do
        #put :reorder
        get :monthlyIncome
        get :yearlyIncome
        get :monthlyExpense
        get :yearlyExpense
      end
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
