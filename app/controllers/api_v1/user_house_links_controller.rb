class ApiV1::UserHouseLinksController < ApiV1::BaseController
  before_filter :require_user, :only => [:index, :show, :create, :update, :destroy, :search]
  skip_before_action :verify_authenticity_token
  before_filter :load_user, :only => [:index]
  before_filter :load_house, :only => [:index]
  
  def index
      if (@user)
        @userhouselinks = @user.user_house_links 
      elsif (@house)
        @userhouselinks = @house.user_house_links
      else
        @userhouselinks = UserHouseLink.all
      end
  end
  
  def create
    if params[:user_house_link][:created_by].nil?
       params[:user_house_link][:created_by] = current_user.id
    end 
    
    if(params[:user_house_link][:created_by] != current_user.id)
      @errMsg = "Login user is different from created_by user attribute in request payload."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
      return
    end

    @userhouselink = UserHouseLink.create(params[:user_house_link])
    if @userhouselink.save
      render 'show', :status => :created
    else
      @errMsg = @userhouselink.errors.full_messages
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def show
    @userhouselink = UserHouseLink.find(params[:id])
  end

  def update
    @userhouselink = UserHouseLink.find(params[:id]) 
    if current_user.admin? || current_user.owner?(@userhouselink.house) # only house owner or admin can modify
      @userhouselink.updated_by = current_user.id
      if @userhouselink.update_attributes(params[:user_house_link])
        flash[:user_house_link] = "User house link updated!"
        render 'show', :status => :ok
      else
        @errMsg = @userhouselink.errors.full_messages
        print @errMsg 
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is neither admin nor house owner."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def destroy
    @userhouselink = UserHouseLink.find(params[:id])
    if current_user.admin? || current_user.owner?(@userhouselink.house) # only house owner or admin can delete
      if @userhouselink.destroy
         render 'destroy', :status => :ok
       else
         @errMsg = @userhouselink.errors.full_messages
         print @errMsg 
         render 'error', :status => :unprocessable_entity
      end   
    else
      @errMsg = "User is neither admin nor house owner."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def load_user
    user_id = params[:user_id]
    if user_id
      @user = User.find(user_id)
    end
  end
  
  def load_house
    house_id = params[:house_id]
    if house_id
      @house = House.find(house_id)
    end
  end
  
end
