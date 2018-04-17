class ApiV1::PaymentsController < ApiV1::BaseController
  before_filter :require_user, :only => [:index, :show, :create, :update, :destroy]
  skip_before_action :verify_authenticity_token
  
  def index
      @payments = Payment.all
  end
  
  def create
    if params[:payment][:user_house_contract_id].nil?
        @errMsg = "Contract id can not be null."
        print @errMsg 
        render 'error', :status => :unprocessable_entity
        return
    end
    params[:payment][:created_by] = current_user.id
    user_house_contract = UserHouseContract.find(params[:payment][:user_house_contract_id])
     
    if !isAuth user_house_contract
        @errMsg = "User is not authorized for receivables."
        print @errMsg 
        render 'error', :status => :unprocessable_entity
        return
    end
    
    @payment = Payment.create(params[:payment])
    
    if @payment.save
      render 'show', :status => :created
    else
      @errMsg = @payment.errors.full_messages[0]
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def show
    @payment = Payment.find(params[:id])
    user_house_contract = UserHouseContract.find(@payment.user_house_contract_id)
    if !isAuth user_house_contract
        @errMsg = "User is not authorized for receivables."
        print @errMsg 
        render 'error', :status => :unprocessable_entity
        return
    end
    
  end

  def update
    @payment = Payment.find(params[:payment][:id])
    user_house_contract = UserHouseContract.find(@payment.user_house_contract_id)
    if !isAuth user_house_contract
        @errMsg = "User is not authorized for receivables."
        print @errMsg 
        render 'error', :status => :unprocessable_entity
        return
    end
    
    @payment.updated_by = current_user.id
    if @payment.update_attributes(params[:payment])
      flash[:community] = "Payment updated!"
      render 'show', :status => :ok
    else
      @errMsg = @payment.errors.full_messages[0]
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def destroy
    @payment = Payment.find(params[:id])
    user_house_contract = UserHouseContract.find(@payment.user_house_contract_id)
    if !isAuth user_house_contract
        @errMsg = "User is not authorized for receivables."
        print @errMsg 
        render 'error', :status => :unprocessable_entity
        return
    end
    @payment.delete 
    render 'destroy', :status => :ok
  end
  
  def isAuth user_house_contract
    house = user_house_contract.house
    return true if current_user.admin? ||
                current_user.land_lord?(house) ||
                current_user.accountant?(house)
  end

end
