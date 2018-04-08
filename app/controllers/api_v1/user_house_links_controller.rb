class ApiV1::UserHouseLinksController < ApiV1::BaseController
  before_filter :require_user, :only => [:index, :show, :create, :update, :destroy, :search]
  skip_before_action :verify_authenticity_token
  before_filter :load_user, :only => [:index]
  before_filter :load_house, :only => [:index]
  
  def index
      if (@user)
        @userhouselinks = @user.user_house_links.includes(:house).order('houses.name ASC')
      elsif (@house)
        @userhouselinks = @house.user_house_links.includes(:house).order('houses.name ASC')
      else
        @userhouselinks = UserHouseLink.all.includes(:house).order('houses.name ASC')
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
    print "Current UserHouseLink record Id=" + @userhouselink.id.to_s
    if isAuth(@userhouselink.house)
      @userhouselink.updated_by = current_user.id
      #check Update Type
      permission = 0
      if(params[:updateType] == "land_lord")
          print "\n User wants to change landLord of the house"
          permission = User::USER_ACL::LAND_LORD
      elsif (params[:updateType] == "tenant")
          print "\n User wants to change tenant of the house"
          permission = User::USER_ACL::TENANT
      end #end of main if
      updatePermissionOfTheHouse(params[:updateType], permission)
    else
      @errMsg = "User is not authorized to perform update on the house user link."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def updatePermissionOfTheHouse (updateType, aclNumber)
    userIdParam = updateType + "_id"
    @user = User.find(params[userIdParam])
    @house = House.find(params[:house_id])
    print "\n Request is to make the user " +  @user.fullName + " #{updateType} of the house " + @house.name
    @userhouselink_new = UserHouseLink.where(:user => @user, :house => @house).take #There is only one user/house combination
    if !(@userhouselink_new.nil?) #house user link already exists
      print "\n House and User link thats going to be promoted to #{updateType} is =" + @userhouselink_new.id.to_s
      if(@userhouselink_new.send("#{updateType}?".to_sym))
        print "\n User =" + @user.fullName + " is already a #{updateType} of the house " + @house.name + ", do nothing."  
      else
        print "\n Ok user #{@user.fullName} is not #{updateType} of the house #{@house.name}, lets update." 
        @userhouselink_new.role = @userhouselink_new.role + aclNumber
        @userhouselink_new.updated_by = current_user.id
        if @userhouselink_new.save
          flash[:user_house_link] = "\n House has been updated with the new #{updateType}"
        else
          @errMsg = "Problem updating house with new #{updateType}."
          print @errMsg
          @errMsg = @userhouselink_new.errors.full_messages
          print @errMsg  
          render 'error', :status => :unprocessable_entity
          return      
        end  
      end
    else 
      print "\n House " + @house.name + " and User " + @user.fullName + " link never exists before"
      @userhouselink_new = UserHouseLink.create(:user_id => params[userIdParam], :house_id => params[:house_id],
                                                :role => aclNumber,
                                                :created_by => current_user.id)
      #@userhouselink_new.user_id = params[userIdParam]
      #@userhouselink_new.role = aclNumber
      if @userhouselink_new.save
        flash[:user_house_link] = "\n House and user association is created successfuly"
      else
        @errMsg = "Problem updating house with new #{updateType}."
        print @errMsg
        @errMsg = @userhouselink_new.errors.full_messages
        print @errMsg  
        render 'error', :status => :unprocessable_entity
        return      
      end
    end #end of updating user house association for the new user
    
    print "\n House and User link thats going to be demoted from #{updateType} is =" + @userhouselink.id.to_s
    if(@userhouselink.send("#{updateType}?".to_sym))
      print "\n Current user is a #{updateType} of the house, lets demote him."
      @userhouselink.role = @userhouselink.role - aclNumber
      if(@userhouselink.role <= 0)
        print "\n Role of the Current user house link " + @userhouselink.id.to_s + " is zero. ignore it."
      end
      if @userhouselink.save
        flash[:user_house_link] = "\n Previous #{updateType} has been removed from the house"
        render 'show', :status => :ok 
      else
        print "Problem removing the old #{updateType} from house."
        @errMsg = @userhouselink.errors.full_messages
        print @errMsg 
        render 'error', :status => :unprocessable_entity
        return
      end
    else
      print "\n Current user is not a #{updateType} of the house. Ignore and do nothing"
      flash[:user_house_link] = "\n User house link is updated successfully."
      render 'show', :status => :ok 
    end
  end
  
  def destroy
    @userhouselink = UserHouseLink.find(params[:id])
    if isAuth(@userhouselink.house) # only house owner or admin can delete
      if @userhouselink.destroy
         render 'destroy', :status => :ok
       else
         @errMsg = @userhouselink.errors.full_messages
         print @errMsg 
         render 'error', :status => :unprocessable_entity
      end   
    else
      @errMsg = "User is neither admin nor house owner nor a creator."
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
  
  def isAuth (house)
    current_user.admin? || current_user.house_created?(house) || current_user.land_lord?(house)# only house owner or admin can modify
  end
  
end
