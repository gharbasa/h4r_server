class ApiV1::UsersController < ApiV1::BaseController
  #before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:index, :show, :edit, :update, :destroy, :search, :verified]
  skip_before_action :verify_authenticity_token
  
  def new
    @user = User.new
  end
    
  def index
    @users = User.all
  end
  
  def create
    params[:user][:created_by] = (current_user == nil)? nil:current_user.id

    processAvatar if !params[:user][:avatar].nil?
    @user = User.create(params[:user])
    if @user.save
      #if !(current_user || false)
        #create session and login the user by default
        #session = Usersession.new(:login => @user.login, :password => @user.login, :remember_me => true)
        #session.save
        #print "User is not logged-in, new user is automatically logged-in."
      #end
      UserMailer.welcome_email(@user).deliver_now #deliver_later
      render 'show', :status => :created
    else
      @errMsg = @user.errors.full_messages
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def show
    @user = @current_user
    if defined?(@user) and @user.id != params[:id]
      @user = User.find(params[:id]) 
      authorize! :read, @user
    end
    @user
  end

  def edit
    @user = @current_user
  end
  
  def update
    @user = User.find(params[:id]) # makes our views "cleaner" and more consistent
    if current_user_session.user.id == @user.id || current_user.admin?
      @user.updated_by = current_user.id
      #@user.avatar = processAvatar if !params[:user][:avatar].nil? 
      processAvatar if !params[:user][:avatar].nil?
      
      if @user.update_attributes(params[:user])
        flash[:notice] = "Account updated!"
        #redirect_to account_url
        #TODO: Send him email notification
        render 'show', :status => :ok
      else
        @errMsg = @user.errors.full_messages
        print @errMsg
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "Only login user or admin can modify user record."
      print @errMsg
      render 'error', :status => :unprocessable_entity
    end
  end
  
  #To mark that the user is verified,no email notification
  def verified
    @user = User.find(params[:id]) 
    if current_user.admin? # only admin can mark house as verified
      @user.updated_by = current_user.id
      @user.verified = true
      if @user.save
        flash[:house] = "User is been successfully verified!"
        render 'show', :status => :ok
      else
        @errMsg = @user.errors.full_messages
        print @errMsg
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is not admin."
      print @errMsg
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    if current_user_session.user.id == @user.id || current_user.admin?
      @user.deactivate! 
      current_user_session.destroy if current_user_session.user.id == @user.id
      #TODO: Send email to admin that the user is deactivated  
      render 'destroy', :status => :ok
    else      
      @errMsg = @user.errors.full_messages
      print @errMsg
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def search
    print "user wants to search users here."
    users = User.arel_table
    @users = if params[:name]
                 User.where(users[:fname].matches("%#{params[:name]}%")
                                          .or(users[:mname].matches("%#{params[:name]}%"))
                                          .or(users[:lname].matches("%#{params[:name]}%")))
              else 
                 []
               end
    
  end
  
  def processAvatar
    avatar = params[:user][:avatar]
    #if User.isDefaultAvatar avatar
    #  params[:user][:avatar] = ""
    #  return
    #end
    
    if (avatar.is_a?(String)) #Its a URL
      print "No image base64 data in the avatar image, ignore processing image."
      params[:user][:avatar] = ""
      return 
    end
    
    data = StringIO.new(Base64.decode64(avatar[:data]))
    data.class.class_eval { attr_accessor :original_filename, :content_type }
    data.original_filename = avatar[:filename]
    data.content_type = avatar[:content_type]
    params[:user][:avatar] = data
  end
end
