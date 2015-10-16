class ApiV1::BaseController < ApplicationController
  helper :all
  helper_method :current_user_session, :current_user
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
  
  # check_authorization
  # load_and_authorize_resource
  #rescue_from CanCan::AccessDenied do |exception|
  #  redirect_to root_url, :alert => exception.message
  #end
  
  def login_from_basic_auth
    authenticate_with_http_basic do |login, password|
      @current_user_session = Usersession.create(:email=>login, :password=>password, :remember_me => true)
      if !(@current_user_session.save)
        print @current_user_session.errors.full_messages
        request_http_basic_authentication
      end
    end
    @current_user_session
  end
  
  def require_user
    unless current_user
      store_location
      #flash[:notice] = "You must be logged in to access this page"
      print "You must be logged in to access this page"
      #redirect_to new_user_session_url
      render 'errors', :status => :unauthorized
      return false
    end
  end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        print "You must be logged out to access this page"
        render 'errors', :status => :unauthorized
        return false
      end
    end
    
    def store_location
      session[:return_to] = request.url
    end
    
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
    
  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = Usersession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      if(current_user_session != nil)
        @current_user = (current_user_session && current_user_session.user)# || login_from_basic_auth.user
      else 
        @current_user = nil #login_from_basic_auth.user
        print "User is not logged-in, not a valid session."
        #render 'errors', :status => :unprocessable_entity
      end
    end
end
