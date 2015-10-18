class ApiV1::NotificationsController < ApiV1::BaseController
  #before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:index, :create, :show, :edit, :update, :destroy]
  before_filter :load_notification_type, :only => [:index]
  before_filter :load_user, :only => [:index]
  skip_before_action :verify_authenticity_token
  
  def new
    @notification = Notification.new
  end
    
  def index
    #if @notification_type 
    #  @notifications = Notification.where(:notification_type => @notification_type, :active => true)  
    #else
    #  if(params[:user_id].nil?)
    #     user = current_user
    #  else
    #     user = User.find(params[:user_id])
    #  end
     # @notifications = Notification.where(:active => true, :user => user)
     if(@user)
       @notifications = Notification.where(:user => @user)
     elsif @notification_type 
       @notifications = Notification.where(:notification_type => @notification_type)
     else
       @notifications = Notification.all
     end
    #end
  end
  
  def create
    if params[:notification][:created_by].nil?
       params[:notification][:created_by] = current_user.id
    end 
    
    if(params[:notification][:created_by] != current_user.id)
      @errMsg = "Login user is different from created_by user attribute in request payload."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
      return
    end
    
    @notification = Notification.create(params[:notification])
    @notification.created_by = current_user.id 
    if @notification.save
      render 'show', :status => :created
    else
      @errMsg = @notification.errors.full_messages
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def show
    @notification = Notification.find(params[:id])
  end

  def update
    @notification = Notification.find(params[:id]) # makes our views "cleaner" and more consistent
    if current_user.admin? #only admin can update notifications
      @notification.updated_by = current_user.id
      if @notification.update_attributes(params[:notification])
        flash[:notice] = "Notification updated!"
        render 'show', :status => :ok
      else
        @errMsg = @notification.errors.full_messages
        print @errMsg 
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "Only admin update notification"
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def destroy
    @notification = Notification.find(params[:id])
    if current_user.admin?
      @notification.deactivate! 
      render 'destroy', :status => :ok
    else
      @errMsg = @notification.errors.full_messages
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def load_notification_type
    notification_type_id = params[:notification_type_id]

    if notification_type_id
      @notification_type = NotificationType.find(notification_type_id)
    end
  end
  
  def load_user
    user_id = params[:user_id]
    if user_id
      @user = User.find(user_id)
    end
  end
end
