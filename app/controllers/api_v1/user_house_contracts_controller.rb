class ApiV1::UserHouseContractsController < ApiV1::BaseController
  before_filter :require_user, :only => [:index, :show, :create, :update, :destroy]
  skip_before_action :verify_authenticity_token
  before_filter :load_user, :only => [:index]
  before_filter :load_house, :only => [:index]

  def index
      if (@user)
        @user_house_contracts = UserHouseContract.where(user: @user)
      elsif (@house)
        @user_house_contracts = UserHouseContract.where(house: @house)
      else
        @user_house_contracts = UserHouseContract.all
      end
  end
  
  def create
    
      params[:user_house_contract][:created_by] = current_user.id
      
      if(params[:renew] == true) 
          print "This is a renew contract"
          @previousContract = UserHouseContract.find(params[:from_contract_id])
          if(@previousContract.nil?)
              @errMsg = "Invalid Previous contract"
              print @errMsg
              render 'error', :status => :unprocessable_entity
              return
          end    
      end

      @user_house_contract = UserHouseContract.create(params[:user_house_contract])
      
      if @user_house_contract.save
        @previousContract.next_contract_id = @user_house_contract.id
        @previousContract.save
        render 'show', :status => :created
      else
        @errMsg = @user_house_contract.errors.full_messages
        print @errMsg
        render 'error', :status => :unprocessable_entity
      end
  end
  
  def show
    @user_house_contract = UserHouseContract.find(params[:id])
  end

  def update
    @user_house_contract = UserHouseContract.find(params[:id])
    @house = House.find(@user_house_contract.house_id)
    #@userhouselink = @user_house_contract.user_house_link
    if isAuth(@house) # only house owner or admin can create contract entry
      @user_house_contract.updated_by = current_user.id
      #if !@user_house_contract.active?
        #if (!params[:user_house_contract][:active].nil? && 
        #    ((params[:user_house_contract][:active] == true) || (params[:user_house_contract][:active] == 1))) 
          #user is trying to make this contract active
         # user_house_contracts = findHouseContracts @userhouselink.house
          #if contractActive? user_house_contracts
          #    @errMsg = "House has at least one contract active"
          #    print @errMsg 
          #    render 'error', :status => :unprocessable_entity
          #    return
          #end
        #end
      #end
      contract_start_date = Date.strptime(params[:contract_start_date], "%m/%d/%Y")
      contract_end_date = Date.strptime(params[:contract_end_date], "%m/%d/%Y")
      if @user_house_contract.update_attributes(:contract_start_date => contract_start_date, :contract_end_date => contract_end_date,
                                                        :annual_rent_amount => params[:annual_rent_amount], :monthly_rent_amount => params[:monthly_rent_amount],
                                                        :note => params[:note], :active => params[:active])
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
  
  def activate
    @user_house_contract = UserHouseContract.find(params[:id])
    @userhouselink = @user_house_contract.user_house_link
    if current_user.admin? || current_user.owner?(@userhouselink.house) # only house owner or admin can create contract entry
      @user_house_contract.activate! 
      render 'show', :status => :ok
    else
      @errMsg = "User is neither admin nor house owner."
      render 'error', :status => :unprocessable_entity
    end
  end

  def deactivate
      destroy
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
  
  def isAuth (house)
    current_user.admin? || current_user.house_created?(house) || current_user.land_lord?(house)# only house owner or admin can modify
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
