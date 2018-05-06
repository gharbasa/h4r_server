class ApiV1::TicketsController < ApiV1::BaseController
  before_filter :require_user, :only => [:index, :destroy, :update, :activate, :inactivate]
  skip_before_action :verify_authenticity_token
  before_filter :load_user, :only => [:index, :create, :destroy, :update, :activate, :inactivate]
  
  def index
    if current_user.admin?
      if(params[:status].nil? || params[:status] == "0")
        @tickets = Ticket.all.order(created_at: :desc)
      else
        @tickets = Ticket.where(:status => params[:status]).order(created_at: :desc)
      end
    else
      @tickets = Ticket.where(:created_by => current_user.id).order(created_at: :desc)
    end
  end
  
  def create
    if(!current_user.nil?)
      params[:ticket][:created_by] = current_user.id
    end
       
    if(params[:ticket][:subject].nil? || params[:ticket][:description].nil?) 
      @errMsg = 'Empty ticket can not be created'
      print @errMsg 
      render 'error', :status => :unprocessable_entity
      return
    end
    @ticket = Ticket.create(params[:ticket])
    if @ticket.save
      render 'show', :status => :created
    else
      @errMsg = @ticket.errors.full_messages
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def show
    @ticket = Ticket.find(params[:id])
  end

  def update
    @ticket = Ticket.find(params[:id]) 
    if isAuth @ticket  # only ticket owner or admin can update
      @ticket.updated_by = current_user.id
      params[:ticket][:status] = @ticket.status if params[:ticket][:status].nil?
      if @ticket.update_attributes(params[:ticket])
        flash[:ticket] = "Ticket updated!"
        render 'show', :status => :ok
      else
        @errMsg = @ticket.errors.full_messages
        print @errMsg
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is neither admin nor created the ticket."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  #To mark that the ticket is inactivated, email send to owner?
  def activate
    @ticket = Ticket.find(params[:id]) 
    if isAuth @ticket  # only ticket owner or admin can update
      @ticket.updated_by = current_user.id
      @ticket.active = true
      if @ticket.save
        flash[:ticket] = "Ticket has been successfully activated!"
        render 'show', :status => :ok
      else
        @errMsg = @ticket.errors.full_messages
        print @errMsg 
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "user is not authorized to update."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  
  def destroy
    @ticket = Ticket.find(params[:id])
    if isAuth @ticket  # only ticket owner or admin can update
      @ticket.deactivate! 
      render 'destroy', :status => :ok
    else
      @errMsg = "user is not authorized to update."
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
  
  def isAuth ticket  # only ticket owner or admin can update ticket
    current_user.admin? || (ticket.created_by == current_user.id)
  end
end
