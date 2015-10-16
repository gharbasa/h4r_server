class ApiV1::UserHouseContractsController < ApiV1::BaseController
  before_filter :require_user, :only => [:index, :show, :create, :update, :destroy]
  skip_before_action :verify_authenticity_token
  before_filter :load_user, :only => [:index]
  before_filter :load_house, :only => [:index]
  
  def index
      if (@user)
        houselinks = @user.user_house_links
        houselink_ids = []
        houselinks.each do |t|
          houselink_ids.push(t.id)
        end
        @user_house_contracts = UserHouseContract.where(user_house_link_id: houselink_ids)
      elsif (@house)
        @user_house_contracts = findHouseContracts @house
      else
        @user_house_contracts = UserHouseContract.all
      end
  end
  
  def create
    if(params[:user_house_contract][:created_by] != current_user.id)
      @errMsg = "Login user is different from created_by user attribute in request payload."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
      return
    end
    @userhouselink = UserHouseLink.find(params[:user_house_contract][:user_house_link_id])
    if current_user.admin? || current_user.owner?(@userhouselink.house) # only house owner or admin can create contract entry
      user_house_contracts = findHouseContracts @userhouselink.house
      if contractActive? user_house_contracts
        @errMsg = "House has at least one contract active"
        print @errMsg 
        render 'error', :status => :unprocessable_entity
        return
      end
      
      @user_house_contract = UserHouseContract.create(params[:user_house_contract])
      if @user_house_contract.save
        render 'show', :status => :created
      else
        @errMsg = @user_house_contract.errors.full_messages
        print @errMsg
        render 'error', :status => :unprocessable_entity
      end
    else
        @errMsg = "User is neither admin nor house owner"
        print @errMsg 
        render 'error', :status => :unprocessable_entity  
    end
  end
  
  def show
    @user_house_contract = UserHouseContract.find(params[:id])
  end

  def update
    @user_house_contract = UserHouseContract.find(params[:id])
    @userhouselink = @user_house_contract.user_house_link
    if current_user.admin? || current_user.owner?(@userhouselink.house) # only house owner or admin can create contract entry
      @user_house_contract.updated_by = current_user.id
      if !@user_house_contract.active?
        if (!params[:user_house_contract][:active].nil? && 
            ((params[:user_house_contract][:active] == true) || (params[:user_house_contract][:active] == 1))) 
          #user is trying to make this contract active
          user_house_contracts = findHouseContracts @userhouselink.house
          if contractActive? user_house_contracts
              @errMsg = "House has at least one contract active"
              print @errMsg 
              render 'error', :status => :unprocessable_entity
              return
          end
        end
      end
      
      if @user_house_contract.update_attributes(params[:user_house_contract])
        flash[:user_house_contract] = "User House Contract updated!"
        render 'show', :status => :ok
      else
        @errMsg = @user_house_contract.errors.full_messages
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is neither admin nor house owner."
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def destroy
    @user_house_contract = UserHouseContract.find(params[:id])
    @userhouselink = @user_house_contract.user_house_link
    if current_user.admin? || current_user.owner?(@userhouselink.house) # only house owner or admin can create contract entry
      @user_house_contract.deactivate! 
      render 'destroy', :status => :ok
    else
      @errMsg = "User is neither admin nor house owner."
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def findHouseContracts (house)
    houselinks = house.user_house_links
    houselink_ids = []
    houselinks.each do |t|
      houselink_ids.push(t.id)
    end
    user_house_contracts = UserHouseContract.where(user_house_link_id: houselink_ids)
  end
  
  def contractActive? (user_house_contracts)
    found = false
    user_house_contracts.each do |t|
      found = true if t.active
    end
    found
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
