class ApiV1::UserHouseContractsController < ApiV1::BaseController
  before_filter :require_user, :only => [:index, :show, :create, :update, :destroy]
  skip_before_action :verify_authenticity_token
  before_filter :load_user, :only => [:index]
  before_filter :load_house, :only => [:index]

  def index
      if (@user)
        @user_house_contracts = UserHouseContract.where(user: @user).includes(:house).order('houses.name ASC')
      elsif (@house)
        @user_house_contracts = UserHouseContract.where(house: @house)
      else
        if(params[:community_id].nil?)
          @user_house_contracts = UserHouseContract.all.includes(:house).order('houses.name ASC')
        else
          community = Community.find(params[:community_id])
          @user_house_contracts = UserHouseContract.where(:house => community.houses).includes(:house).order('houses.name ASC')
        end
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
      date_format = Rails.configuration.app_config[:date_format]
      start_date = DateTime.strptime(params[:contract_start_date], date_format).to_date
      end_date = DateTime.strptime(params[:contract_end_date], date_format).to_date
      params[:contract_start_date] = start_date.to_s(:custom_datetime)
      params[:contract_end_date] = end_date.to_s(:custom_datetime)
      params[:created_by] = current_user.id
      @user_house_contract = UserHouseContract.create(params[:user_house_contract])
      
      if @user_house_contract.save
        if(params[:renew] == true)
          @previousContract.next_contract_id = @user_house_contract.id
          #If the current new contract (@user_house_contract) is a onetime payment contract, then do not inactivate the previous contract.   
          @previousContract.active = false if (@user_house_contract.onetime_contract != false) 
          @previousContract.save
        end
        #if the contract is tenant, then mark the house as not open any more
        if(@user_house_contract.tenant?)
          house = House.find(@user_house_contract.house_id)
          house.is_open = false;
          house.save
        end
        
        if(@user_house_contract.onetime_contract == true)
           #If the contract is a onetime payment, create a payment with total amount and mark contract inactive
           logger.info("User wants to create onetime pay contract.")
           createOneTimePayment @user_house_contract
        end
        
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
    previousOnetimePayflag = @user_house_contract.onetime_contract
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
      date_format = Rails.configuration.app_config[:date_format]
      contract_start_date = Date.strptime(params[:contract_start_date], date_format)
      contract_end_date = Date.strptime(params[:contract_end_date], date_format)
      if @user_house_contract.update_attributes(:contract_start_date => contract_start_date, :contract_end_date => contract_end_date,
                                                        :annual_rent_amount => params[:annual_rent_amount], :monthly_rent_amount => params[:monthly_rent_amount],
                                                        :note => params[:note], :active => params[:active], :contract_type => params[:contract_type],
                                                        :onetime_contract => params[:onetime_contract])
        
        if(previousOnetimePayflag == false && @user_house_contract.onetime_contract == true)
           #If the contract is a onetime payment, create a payment with total amount and mark contract inactive
           logger.info("User wants to update existing contract to onetime pay contract.")
           createOneTimePayment @user_house_contract
        end
        
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
    if current_user.admin? || current_user.land_lord?(@userhouselink.house) # only house owner or admin can create contract entry
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
    if current_user.admin? || current_user.land_lord?(@userhouselink.house) # only house owner or admin can create contract entry
      @user_house_contract.deactivate! 
      render 'destroy', :status => :ok
    else
      @errMsg = "User is neither admin nor house owner."
      render 'error', :status => :unprocessable_entity
    end
  end
  
  #received payments from this contract
  def receivedPayments
    months = current_user.subscriptionType * 12 #months
    user_house_contract = UserHouseContract.find(params[:id])
    @payments = Payment.where(:created_at => months.months.ago..Time.now, :user_house_contract => user_house_contract,  :active => true).order(payment_date: :desc)
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
  
  def createOneTimePayment user_house_contract
    payment = Payment.create(:user_house_contract_id => user_house_contract.id,
                             :amount => user_house_contract.annual_rent_amount,
                             :payment_date => user_house_contract.contract_end_date,
                             :note => "System note: Onetime payment contract",
                             :created_by => current_user.id)
    if payment.save
       logger.info("Onetime payment is created successful.")
       user_house_contract.deactivate!
    end
  end
end
