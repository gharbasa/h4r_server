class ApiV1::HousesController < ApiV1::BaseController
  before_filter :require_user, :only => [:index, :show, :create, :update, :destroy, :search, 
                                  :verified,:notes, :create_note, :makeitOpen, :makeitClosed,
                                  :activate, :inactivate, :list4Reports]
  skip_before_action :verify_authenticity_token
  before_filter :load_user, :only => [:index]
  
  def index
    if(params[:community_id].nil?)
      if(@user)
         #@UserHouseLinks = UserHouseLink.where(:user => @user)#House.where(:user_house_links.user => @user)
         @houses = @user.houses.order(name: :asc)
      else
        @houses = House.all.order(name: :asc)
      end
    else
      community = Community.find(params[:community_id])
      @houses = community.houses
    end    
  end
  
  def list4Reports
      if current_user.admin?
        index
      else
        #TODO: do not show the houses that the current is only a tenant.   
      end
  end
  
  def create
    params[:house][:created_by] = current_user.id
     
    if(params[:house][:name].nil? || params[:house][:name] == "") 
      @errMsg = 'House name can not be empty'
      print @errMsg 
      render 'error', :status => :unprocessable_entity
      return
    end
    
    @house = House.create(params[:house])
    @house.verified = false
    if @house.save
      render 'show', :status => :created
    else
      @errMsg = @house.errors.full_messages
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def show
    @house = House.find(params[:id])
  end

  def contracts
    @house = House.find(params[:id])
    @user_house_contracts = @house.user_house_contracts
  end
  
  def update
    @house = House.find(params[:id]) 
    if isAuth @house  # only house owner or admin can update
      @house.updated_by = current_user.id
      if @house.update_attributes(params[:house])
        flash[:house] = "House updated!"
        render 'show', :status => :ok
      else
        @errMsg = @house.errors.full_messages
        print @errMsg
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is neither admin nor house land_lord."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  #To mark that the house is verified, email send to owner?
  def verified
    @house = House.find(params[:id]) 
    if current_user.admin? # only admin can mark house as verified
      @house.updated_by = current_user.id
      @house.verified = true
      if @house.save
        flash[:house] = "House has been successfully verified!"
        @owner = @house.land_lord
        if !@owner.nil?
          #send email to house owner  
          UserMailer.house_verified(@house, @owner).deliver_now #deliver_later  
        end
        render 'show', :status => :ok
      else
        @errMsg = @house.errors.full_messages
        print @errMsg 
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is not admin."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  #To mark that the house is inactivated, email send to owner?
  def inactivate
    @house = House.find(params[:id]) 
    if isAuth @house  # only house owner or admin can update
      @house.updated_by = current_user.id
      @house.active = false
      if @house.save
        flash[:house] = "House has been successfully inactivated!"
        
        #@owner = @house.owner
        #if !@owner.nil?
        #  #send email to house owner  
        #  UserMailer.house_verified(@house, @owner).deliver_now #deliver_later  
        #end
        render 'show', :status => :ok
      else
        @errMsg = @house.errors.full_messages
        print @errMsg 
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is not the owner of the house."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  #To mark that the house is inactivated, email send to owner?
  def activate
    @house = House.find(params[:id]) 
    if isAuth @house  # only house owner or admin can update
      @house.updated_by = current_user.id
      @house.active = true
      if @house.save
        flash[:house] = "House has been successfully activated!"
        
        #@owner = @house.owner
        #if !@owner.nil?
        #  #send email to house owner  
        #  UserMailer.house_verified(@house, @owner).deliver_now #deliver_later  
        #end
        render 'show', :status => :ok
      else
        @errMsg = @house.errors.full_messages
        print @errMsg 
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is not the owner of the house."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  #To mark that the house is open, it is ready for renting
  def makeitOpen
    @house = House.find(params[:id])
    if !isAuth(@house)  # only house owner or admin can update
      @errMsg = "User is not authorized to update house details."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
      return
    end
    
    user_house_contract = @house.activeContractsExists?  
    if(!user_house_contract.nil?)
      @errMsg = "There is an active contract with user '" + user_house_contract.user.fullName + "', can not make it open."
      print @errMsg 
      render 'error', :status => :unprocessable_entity   
      return
    end
    
    @house.updated_by = current_user.id
    @house.is_open = true
    if @house.save
      flash[:house] = "House has been successfully made it open!"
      #@owner = @house.owner
      #if !@owner.nil?
      #  #send email to house owner  
      #  UserMailer.house_verified(@house, @owner).deliver_now #deliver_later  
      #end
      render 'show', :status => :ok
    else
      @errMsg = @house.errors.full_messages
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  #To mark that the house is closed, not ready for rent
  def makeitClosed
    @house = House.find(params[:id])
    if !isAuth(@house)  # only house owner or admin can update
      @errMsg = "User is not authorized to update house details."
      print @errMsg 
      render 'error', :status => :unprocessable_entity   
      return
    end
    
    @house.updated_by = current_user.id
    @house.is_open = false
    if @house.save
      flash[:house] = "House has been successfully made it closed!"
      
      #@owner = @house.owner
      #if !@owner.nil?
      #  #send email to house owner  
      #  UserMailer.house_verified(@house, @owner).deliver_now #deliver_later  
      #end
      render 'show', :status => :ok
    else
      @errMsg = @house.errors.full_messages
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def destroy
    @house = House.find(params[:id])
    if current_user.admin? || current_user.land_lord?(@house) # only house owner or admin can create
      @house.deactivate! 
      render 'destroy', :status => :ok
    else
      @errMsg = "User is neither admin nor house owner."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def search
    print "user wants to search houses here."
    houses = House.arel_table
    @houses = if params[:address]
                 House.where(houses[:addr1].matches("%#{params[:address]}%")
                                          .or(houses[:addr2].matches("%#{params[:address]}%"))
                                          .or(houses[:addr3].matches("%#{params[:address]}%"))
                                          .or(houses[:addr4].matches("%#{params[:address]}%"))
                                          .or(houses[:name].matches("%#{params[:address]}%"))
                                          )
              else 
                 []
               end
  end
  
  def load_user
    user_id = params[:user_id]
    if user_id
      @user = User.find(user_id)
    end
  end
  
  def isAuth house  # only house owner or admin can update house
    current_user.admin? || !current_user.tenantOnly?(house)
  end
end
