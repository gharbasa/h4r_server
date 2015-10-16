class ApiV1::UsersessionController < ApiV1::BaseController
  skip_before_action :verify_authenticity_token
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :destroy]
  
  def new
    @user_session = Usersession.new
  end

  def index
    @user_sessions = User.all
  end
  
  def show
    @user_session = Usersession.find(params[:id])
  end
  
  def create
    #Following code is temporary
    @user = User.find_by_login(params[:login])
    if @user.inactive?
      @errMsg = "Inactive user " + @user.email + " is trying to login. Login rejected."
      #print errMsg
      logger.info(@errMsg)
      render 'errors', :status => :forbidden
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
    
    @user_session = Usersession.create(params[:usersession], :remember_me => true)
    if @user_session.save
      render 'show', :status => :created
    else
      print @user_session.errors.full_messages
      render 'errors', :status => :unprocessable_entity
    end
  end
  
  def destroy
    current_user_session.destroy
    render nothing:true, :status => :accepted
    #redirect_to new_user_session_url
  end
end