class ApiV1::NotificationTypesController < ApiV1::BaseController
  #before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:index, :create, :show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token
  
  def new
    @notification_type = NotificationType.new
  end
    
  def index
    @notification_types = NotificationType.where(:active => true)
  end
  
  def create
    @notification_type = NotificationType.create(params[:notification_type])
    @notification_type.created_by = current_user.id 
    if @notification_type.save
      render 'show', :status => :created
    else
      print @notification_type.errors.full_messages
      render 'errors', :status => :unprocessable_entity
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
        print @notification_type.errors.full_messages
        render 'errors', :status => :unprocessable_entity
      end
    else
      render 'errors', :status => :unprocessable_entity
    end
  end
  
  def destroy
    @notification_type = NotificationType.find(params[:id])
    if current_user.admin?
      @notification_type.deactivate! 
      render 'destroy', :status => :ok
    else
      print @notification_type.errors.full_messages
      render 'errors', :status => :unprocessable_entity
    end
  end
end
