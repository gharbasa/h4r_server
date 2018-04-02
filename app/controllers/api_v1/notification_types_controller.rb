class ApiV1::NotificationTypesController < ApiV1::BaseController
  #before_filter :require_no_user, :only => [:index, :show]
  before_filter :require_user, :only => [:create, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token
  
  def new
    @notification_type = NotificationType.new
  end
    
  def index
    #@notification_types = NotificationType.where(:active => true)
    @notification_types = NotificationType.all
  end
  
  def create
    
    if params[:notification_type][:created_by].nil?
       params[:notification_type][:created_by] = current_user.id
    end 
    
    if(params[:notification_type][:created_by] != current_user.id)
      @errMsg = "Login user is different from created_by user attribute in request payload."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
      return
    end
    
    @notification_type = NotificationType.create(params[:notification_type])
    if @notification_type.save
      render 'show', :status => :created
    else
      @errMsg = @notification_type.errors.full_messages
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def show
    @notification_type = NotificationType.find(params[:id])
  end

  def update
    @notification_type = NotificationType.find(params[:id]) # makes our views "cleaner" and more consistent
    if current_user.admin? #only admin can update notifications
      @notification_type.updated_by = current_user.id
      if @notification_type.update_attributes(params[:notification_type])
        flash[:notice] = "Notification type updated!"
        render 'show', :status => :ok
      else
        @errMsg = @notification_type.errors.full_messages
        print @errMsg 
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "Only admin can create notifications."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def destroy
    @notification_type = NotificationType.find(params[:id])
    if current_user.admin?
      @notification_type.deactivate! 
      render 'destroy', :status => :ok
    else
      @errMsg = @notification_type.errors.full_messages
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
end
