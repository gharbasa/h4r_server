class ApiV1::PaymentsController < ApiV1::BaseController
  before_filter :require_user, :only => [:index, :show, :create, :update, :destroy]
  skip_before_action :verify_authenticity_token
  
  def index
      @payments = Payment.all.order(payment_date: :desc)
  end
  
  def create
    if params[:user_house_contract_id].nil?
        @errMsg = "Contract id can not be null."
        print @errMsg 
        render 'error', :status => :unprocessable_entity
        return
    end
    params[:created_by] = current_user.id
    user_house_contract = UserHouseContract.find(params[:user_house_contract_id])
      
    if !isAuth user_house_contract
        @errMsg = "User is not authorized for receivables."
        print @errMsg 
        render 'error', :status => :unprocessable_entity
        return
    end
    
    date_format = Rails.configuration.app_config[:date_format]
    start_date = DateTime.strptime(params[:payment_date], date_format).to_date
    params[:payment_date] = start_date.to_s(:custom_datetime)
    
    @payment = Payment.create(params)
    
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
