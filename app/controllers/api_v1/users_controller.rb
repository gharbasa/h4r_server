class ApiV1::UsersController < ApiV1::BaseController
  #before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:index, :show, :edit, :update, :destroy, :search, :verified,
                                         :promote2Admin, :demoteFromAdmin, :houseContracts, :resetPassword, :changeSubscription]
  skip_before_action :verify_authenticity_token
  
  def new
    @user = User.new
  end
  
  def index
    if(params[:commnunity_id].nil?) 
      @users = User.all
    else
      community = Community.find(params[:commnunity_id])
      @users = community.users
    end
  end
  
  def create
    params[:user][:created_by] = (current_user == nil)? nil:current_user.id
    params[:user][:entitlement] = User::USER_ACL::DEFAULT_ENTITLEMENT
  
    processAvatar "new"
    #TODO: If the user is created after August month, make the subscriptionType 2, so that the user can view next year report
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
      @errMsg = @user.errors.full_messages[0]
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

  def houseContracts
    @user = User.find(params[:id])
    @user_house_contracts = @user.user_house_contracts
  end
  
  def edit
    @user = @current_user
  end
  
  def update
    @user = User.find(params[:id]) # makes our views "cleaner" and more consistent
    if current_user_session.user.id == @user.id || current_user.admin?
      @user.updated_by = current_user.id
      #@user.avatar = processAvatar if !params[:user][:avatar].nil? 
      processAvatar "update"
      
      if @user.update_attributes(params[:user])
        flash[:notice] = "Account updated!"
        #redirect_to account_url
        #TODO: Send him email notification
        render 'show', :status => :ok
      else
        @errMsg = @user.errors.full_messages[0]
        print @errMsg
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "Only login user or admin can modify user record."
      print @errMsg
      render 'error', :status => :unprocessable_entity
    end
  end

  #Only admin user or own login user can do this operation
  def resetPassword
    @user = User.find(params[:id])
    if current_user_session.user.id == @user.id || current_user.admin?
      if @user.update_attributes(:password => "kichidi123", :password_confirmation => "kichidi123", 
                                              :updated_by => current_user.id)
        flash[:notice] = "Password have been successfully updated!"
        #redirect_to account_url
        #TODO: Send him email notification
        render 'show', :status => :ok
      else
        @errMsg = @user.errors.full_messages[0]
        print @errMsg
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "Only login user or admin can modify user account."
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
        @errMsg = @user.errors.full_messages[0]
        print @errMsg
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is not admin."
      print @errMsg
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def promote2Admin
    @user = User.find(params[:id]) 
    if @user && current_user.admin? # only admin can mark house as verified
      @user.updated_by = current_user.id
      @user.role = User::USER_ACL::ADMIN
      @user.subscriptionType = Rails.configuration.app_config[:ADMIN_DEFAULT_SUBSCRIPTION]
      if @user.save
        flash[:user] = "User is been successfully promoted!"
        render 'show', :status => :ok
      else
        @errMsg = @user.errors.full_messages[0]
        print @errMsg
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is not admin or not a valid user input."
      print @errMsg
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def demoteFromAdmin
    @user = User.find(params[:id]) 
    if @user && current_user.admin? # only admin can mark house as verified
      @user.updated_by = current_user.id
      @user.role = User::USER_ACL::GUEST
      @user.subscriptionType = 1  #When demoted, subscription will fall back to 1
      if @user.save
        flash[:house] = "User is been successfully demoted!"
        render 'show', :status => :ok
      else
        @errMsg = @user.errors.full_messages[0]
        print @errMsg
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is not admin or not a valid user input."
      print @errMsg
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def changeSubscription
    @user = User.find(params[:id]) 
    if @user && current_user.admin? # only admin can mark house as verified
      @user.updated_by = current_user.id
      @user.subscriptionType = params[:subscriptionType]
      if @user.save
        flash[:house] = "User subscription successfully updated!"
        render 'show', :status => :ok
      else
        @errMsg = @user.errors.full_messages[0]
        print @errMsg
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "Failed to update subscription, User is not an admin or not a valid user input."
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
      @errMsg = @user.errors.full_messages[0]
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
  
  def forgotPassword
    print "forgotPassword"
    users = User.arel_table
    @users = User.where(:login => params[:login], :email => params[:email],
                            :adhaar_no => params[:adhaar_no],
                            :sex => params[:sex])
    print "Number records size=" + @users.size.to_s 
    if(@users.size == 1)
      print "Ok, lets change the password"
      @user = @users[0]
      @user.update(:password => params[:password], :password_confirmation => params[:password_confirmation]) 
      if @user.save
        flash[:user] = "User is been successfully promoted!"
        render 'show', :status => :ok
      else
        @errMsg = @user.errors.full_messages[0]
        print @errMsg
        render 'error', :status => :unprocessable_entity  
      end  
    else
      @errMsg = "Your credentials did not match. Please try again or contact support."
      print @errMsg
      render 'error', :status => :unprocessable_entity
    end         
  end
  
  def processAvatar (method)
    
    if(method == "new") #default avatar for the newly registered user.
      print "Its a new user registration, assign default avatar."
      avatar = {:data => User::USER_AVATAR_SETTINGS::DEFAULT_AVATAR,
                :filename => User::USER_AVATAR_SETTINGS::DEFAULT_AVATAR_FILENAME,
                :content_type => User::USER_AVATAR_SETTINGS::DEFAULT_AVATAR_FILETYPE
              }
      params[:user][:avatar] = avatar 
    end
    
    avatar = params[:user][:avatar]
    
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
