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
        @errMsg = "User is not authorized for updating receivables."
        print @errMsg 
        render 'error', :status => :unprocessable_entity
        return
    end
    #@payment.delete
    print "Ok making it inactivate."
    @payment.deactivate!
    render 'destroy', :status => :ok
  end
  
  def monthlyPayments
    #If not year , then default current year (what if its jan of the current year, fall back to previous year paymnets)
    year = params[:year]
    house_id = params[:house_id]
    if(house_id.nil?)
      @errMsg = "House id is required field."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
      return
    end
    
    if(year.nil?)
      year = Time.zone.now.year
      print "year=" + year.to_s
      month = Time.zone.now.month
      year = year - 1 if(month == 1) #January, fall back to previous year 
    end
    date_format = Rails.configuration.app_config[:date_format]
    start_date = DateTime.strptime("01-01-#{year}", date_format).to_date #"%d-%m-%Y"
    end_date = DateTime.strptime("31-12-#{year}", date_format).to_date #"%d-%m-%Y"
    #
    contracts = UserHouseContract.where(:house_id => house_id)
    @payments = Payment.where(:active => true, :payment_date => start_date.beginning_of_day..end_date.end_of_day, :user_house_contract => contracts).order(payment_date: :asc)
  end
  
  #past 5 years payment
  def yearlyPayments
    #If not year , then default current year (what if its jan of the current year, fall back to previous year paymnets)
    house_id = params[:house_id]
    if(house_id.nil?)
      @errMsg = "House id is required field."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
      return
    end
    
    year = Time.zone.now.year
    print "year=" + year.to_s
    month = Time.zone.now.month
    year = year - 1 if(month == 1) #January, fall back to previous year 
    startYear = year - 4 #2018 - 4 = 2014, 2015, 2016, 2017 and 2018
    date_format = Rails.configuration.app_config[:date_format]
    start_date = DateTime.strptime("01-01-#{startYear}", date_format).to_date #"%d-%m-%Y"
    end_date = DateTime.strptime("31-12-#{year}", date_format).to_date #"%d-%m-%Y"
    summary = Hash.new
    summary[startYear] = 0
    summary[startYear + 1] = 0
    summary[startYear + 2] = 0
    summary[startYear + 3] = 0
    summary[startYear + 4] = 0
    
    contracts = UserHouseContract.where(:house_id => house_id)
    @payments = Payment.where(:active => true, :payment_date => start_date.beginning_of_day..end_date.end_of_day, :user_house_contract => contracts).order(payment_date: :asc).find_each do |payment|
      summary[payment.paymentYear] += payment.payment  
    end
    
    @yearlySummary = []
    summary.each do |key, value|
      @yearlySummary.push({"year" => key, "value" => value})
    end
  end
  
  def isAuth user_house_contract
    house = user_house_contract.house
    return true if current_user.admin? ||
                current_user.land_lord?(house) ||
                current_user.accountant?(house)
  end

end
