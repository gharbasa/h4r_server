class ApiV1::UserHouseLinksController < ApiV1::BaseController
  before_filter :require_user, :only => [:index, :show, :create, :update, :destroy, :search]
  skip_before_action :verify_authenticity_token
  before_filter :load_user, :only => [:index]
  before_filter :load_house, :only => [:index]
  
  def index
      if (@user)
        #retrieve links that this user associated with(user_id) or created/updated by him
        #also user should have at least one role with the house
        @userhouselinks = UserHouseLink.where('user_house_links.role != 0 and (user_house_links.user_id = ? OR user_house_links.created_by = ? OR user_house_links.updated_by = ?)', @user.id,@user.id,@user.id).includes(:house).order('houses.name ASC')
      elsif (@house)
        @userhouselinks = @house.user_house_links.includes(:house).order('houses.name ASC')
      else 
        if(params[:community_id].nil?)
          @userhouselinks = UserHouseLink.all.includes(:house).order('houses.name ASC')
        else
          community = Community.find(params[:community_id])
          @userhouselinks = UserHouseLink.where(:house => community.houses).includes(:house).order('houses.name ASC')
        end
      end
  end
  
  def create
    params[:user_house_link][:created_by] = current_user.id
    
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
    house = House.find(params[:house_id])
    if !isAuth(house)
      @errMsg = "User is not authorized to update house user link."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
      return
    end
    
    updateType = params[:updateType] #lets say update type is tenant
    permission = 0
    print "\n User wants to change #{updateType} of the house"
    
    if(updateType == "land_lord")
      permission = User::USER_ACL::LAND_LORD
    elsif (params[:updateType] == "tenant")
      permission = User::USER_ACL::TENANT
    elsif (params[:updateType] == "accountant")
      permission = User::USER_ACL::ACCOUNTANT
    elsif (params[:updateType] == "property_mgmt_mgr")
      permission = User::USER_ACL::PROPERTY_MGMT_MGR
    elsif (params[:updateType] == "property_mgmt_emp")
      permission = User::USER_ACL::PROPERTY_MGMT_EMP
    elsif (params[:updateType] == "agency_collection_mgr")
      permission = User::USER_ACL::AGENCY_COLLECTION_MGR
    elsif (params[:updateType] == "agency_collection_emp")
      permission = User::USER_ACL::AGENCY_COLLECTION_EMP
    end #end of main if
    
    #if(params[updateType] == true) #Is there a previous tenant already associated with a house
    org_user_id_param = "org_#{updateType}_id"
    org_user_id = params[org_user_id_param]
    if (org_user_id.nil?)
      print "\n There is No previous #{updateType} to the house #{params[:house_id]}"  
    else
      user = User.find(org_user_id)
      print "\n There is a previous #{updateType} to the house #{params[:house_id]}, its user #{user.fullName}"
      @userhouselink = UserHouseLink.where(:user => user, :house => house).take #There is only one user/house combination
    end
    updateUserHouseLink(permission)
    #else #There is no previous tenant associated with the house
    #   updatePermissionOfTheHouse(permission)
    #end
  end
  
  def updateUserHouseLink (aclNumber)
    updateType = params[:updateType]
    newUserIdParam = updateType + "_id"
    newUserId = params[newUserIdParam]
    @house = House.find(params[:house_id])
    if !(newUserId.nil?)
      @user = User.find(newUserId)
      print "\n Request is to make the user " +  @user.fullName + " #{updateType} of the house " + @house.name
      @userhouselink_new = UserHouseLink.where(:user => @user, :house => @house).take #There is only one user/house combination
      if !(@userhouselink_new.nil?) #house user link already exists
        print "\n There is an existing house and user link, House and User link thats going to be promoted to #{updateType} is =" + @userhouselink_new.id.to_s
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
        @userhouselink_new = UserHouseLink.create(:user_id => params[newUserIdParam], :house_id => params[:house_id],
                                                  :role => aclNumber,
                                                  :created_by => current_user.id)
        #@userhouselink_new.user_id = params[newUserIdParam]
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
    else
      print "\n User wants to remove #{updateType} from the house #{@house.name}"
    end #end of check for new user
    
    if(!(@userhouselink.nil?) && @userhouselink.send("#{updateType}?".to_sym))
      print "\n House and User link thats going to be demoted from #{updateType} is =" + @userhouselink.id.to_s
      @userhouselink.role = @userhouselink.role - aclNumber
      @userhouselink.updated_by = current_user.id
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
      print "\n There is no #{updateType} to the house. Ignore and do nothing"
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
  
  #List the house contract based on the houseid/userid/roleId combination
  def contracts
    #if isAuth(@userhouselink.house) # only house owner or admin can delete
      id = params[:id]
      print "contracts id=" + id.to_s
      #houseId_userId_roleNumber
      houseId,userId,role =  id.to_s.split("_")
      print "houseId=" + houseId.to_s + ", userId=" + userId.to_s + ", role=" + role.to_s
      if(houseId && userId && role)
        @user_house_contracts = UserHouseContract.where(:house_id => houseId, :user_id => userId, :role => role)
      else
        @errMsg = "Invalid input format."
        print @errMsg 
        render 'error', :status => :unprocessable_entity 
      end
      #
    #end
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
