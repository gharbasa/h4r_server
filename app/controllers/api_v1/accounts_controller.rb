class ApiV1::AccountsController < ApiV1::BaseController
  before_filter :require_user, :only => [:index, :show, :create, :update, :destroy, :houses, :markings, :mark]
  skip_before_action :verify_authenticity_token
  
  def index
      #Show accounts that the user is a owner to the house that it is associated with.
      if current_user.admin?
        @accounts = Account.all.order(id: :asc)
      else
        houses = current_user.houses
        houses.select {|house| !current_user.tenantOnly? house} #Exclude houses that the login user is a tenantOnly
        @accounts = []
        houses.each do |house|
            @accounts.push(house.account) unless house.account.nil? || @accounts.include?(house.account)
        end
      end
  end
  
  def create
    #Only admin user can create account
    render 'error', :status => :unprocessable_entity if !current_user.admin? 
    
    params[:account][:created_by] = current_user.id
    
    @account = Account.create(params[:account])
    
    if @account.save
      render 'show', :status => :created
    else
      @errMsg = @account.errors.full_messages
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def show
    @account = Account.find(params[:id])
  end

  def houses
    @account = Account.find(params[:id])
    @houses = @account.houses
  end
  
  def update
    @account = Account.find(params[:id]) 
    if isAuthorized? @account
      @account.updated_by = current_user.id
      if @account.update_attributes(params[:account])
        flash[:account] = "Account updated!"
        render 'show', :status => :ok
      else
        @errMsg = @account.errors.full_messages
        print @errMsg 
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is neither admin nor account owner."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def destroy
    @account = Account.find(params[:id])
    if isAuth @account
      @account.deactivate! 
      render 'destroy', :status => :ok
    else
      @errMsg = "User is neither admin nor house owner."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def markings
    account = Account.find(params[:id])
    @account_markings = account.account_markings.order("marking_date desc")
  end
  
  def mark
    account = Account.find(params[:id])
    @account_marking = AccountMarking.create(params)
    @account_marking.marking_date = Time.now
    @account_marking.created_by = current_user.id
    if @account_marking.save
      render 'mark', :status => :created
    else
      @errMsg = @account.errors.full_messages
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  #Yes if Admin
  #For non-admin, there has to be a house associated with the account and the current login user is not a tenant-only  
  def isAuthorized? account
    return true if current_user.admin?
    house = House.where(:account => account)
    return false if (house.nil || current_user.tenantOnly?)
  end
  
end
