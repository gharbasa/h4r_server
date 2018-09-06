class ApiV1::UsersessionController < ApiV1::BaseController
  skip_before_action :verify_authenticity_token
  before_filter :require_no_user, :only => [:new, :create, :federatedLogin]
  before_filter :require_user, :only => [:show, :destroy]
  
  def new
    @user_session = Usersession.new
  end

  def index
    @user = current_user
    if(@user != nil)
      render 'index'
    else
      @errMsg = "User session is not valid"
      print @errMsg
      render 'error', :status => :forbidden
    end
  end
  
  def all #TODO: Pending, not working
    @user_sessions = Usersession.all
  end
  
  def show
    @user = current_user
  end
  
  def create
    
    #User can login through login Id or email
    @user = User.find_by_login(params[:usersession][:login])
    
    if(@user == nil) #May the user entered email to login
       @user = User.find_by_email(params[:usersession][:login])
    end
    
    performLogin nil
    
  end
  
  def federatedLogin
    logger.info("Federated user login")
    if(params[:provider] != nil && params[:provider] == "FACEBOOK")
        userParams = params[:facebook]
        logger.info("Its facebook user login")
        @user = User.find_by_facebook_user_id(userParams[:id]) #email is optional in facebook account
        #@user = User.find_by_email(userParams[:email]) #email is optional in facebook a/c
        federated_user_type = User::FEDERATED_USER::FACEBOOK
    end
    if(@user != nil)
        logger.info("facebook user account already exists, lets verify and create usersession")
        ##Cross verify all the user details that facebook provides, at least facebookid, lastname and firstname
        #If the user is created through facebook profile, then default password holds good
        if (@user.fname == userParams[:first_name] &&
            @user.lname == userParams[:last_name] && 
            @user.facebook_user_id == userParams[:id] &&
            @user.isFacebookUser)
            performLogin Rails.configuration.defaultPassword
        else
            logger.info("Looks like this federated user is already registered in our system. Going with normal authentication flow.")
            #Otherwise, normal user credentials login flow
            performLogin nil    
        end 
    else
        #create user
        created_by = nil
        entitlement = User::USER_ACL::DEFAULT_ENTITLEMENT
        
        userParams[:email] = (userParams[:id].to_s + "@maaghar.com") if userParams[:email] == nil #email is optional in facebook a/c
        @user = User.create(:email => userParams[:email],
          :password => Rails.configuration.defaultPassword,
          :password_confirmation => Rails.configuration.defaultPassword,
          :login => userParams[:id],
          :fname => userParams[:first_name],
          :lname => userParams[:last_name],
          #:avatar => avatar,
          :federated_user_type => federated_user_type,
          :facebook_user_id => userParams[:id],
          :addr1 => "Facebook address",
          :phone1 => "6318848020"
        )
        
        if (params[:photoUrl] != nil)
          logger.info("There is a facebook avatar..." + params[:photoUrl])
          @user.picture_from_url params[:photoUrl]
        else
          logger.info("There is no facebook avatar... taking default one")
          @user.avatar = User.prepareDefaultAvatar
        end
        
        if @user.save
          UserMailer.welcome_email(@user).deliver_now #deliver_later
          performLogin Rails.configuration.defaultPassword
        else
          @errMsg = @user.errors.full_messages[0]
          print @errMsg 
          render 'error', :status => :unprocessable_entity
        end
    end
  end
    
  def destroy
    current_user_session.destroy
    render nothing:true, :status => :accepted
    #redirect_to new_user_session_url
  end
  
  def performLogin sharedSecret
    if @user && @user.inactive?
      @errMsg = "Inactive user " + @user.email + " is trying to login. Login rejected."
      #print errMsg
      logger.info(@errMsg)
      render 'error', :status => :forbidden
      return
    end
    
    if @user && !@user.active?
      @user.activate!
    end
    if @user && !@user.approved?
      @user.approve!
    end
    if @user && !@user.confirmed?
      @user.confirm!
    end
    #upto here
    
    if(@user != nil)
        email = @user.email
        login = @user.login
    end
    
    sharedSecret = params[:password] if sharedSecret == nil
    
    @user_session = Usersession.create(:login => login, :password => sharedSecret, :remember_me => true)
    
    if @user_session.save
      render 'show', :status => :created
    else
      @errMsg = @user_session.errors.full_messages
      print @errMsg
      render 'error', :status => :unprocessable_entity
    end
  end
end