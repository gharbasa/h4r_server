class ApiV1::CommunitiesController < ApiV1::BaseController
  before_filter :require_user, :only => [:index, :show, :create, :update, :destroy, :search, :verified]
  skip_before_action :verify_authenticity_token
  
  def index
      @communities = Community.all
  end
  
  def create
    if params[:community][:manager_id].nil?
       params[:community][:manager_id] = current_user.id
    end 
    if params[:community][:created_by].nil?
       params[:community][:created_by] = current_user.id
    end 
    
    if(params[:community][:created_by] != current_user.id)
      @errMsg = "Login user is different from created_by user attribute in request payload."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
      return
    end
    
    @community = Community.create(params[:community])
    
    #@house.created_by = current_user.id
    @community.verified = false
    if @community.save
      render 'show', :status => :created
    else
      @errMsg = @community.errors.full_messages
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def show
    @community = Community.find(params[:id])
  end

  def update
    @community = Community.find(params[:id]) 
    if current_user.admin? || current_user.owner?(@community) # only house owner or admin can create
      @community.updated_by = current_user.id
      if @community.update_attributes(params[:community])
        flash[:community] = "Community updated!"
        render 'show', :status => :ok
      else
        @errMsg = @community.errors.full_messages
        print @errMsg 
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is neither admin nor house owner."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  #To mark that the house is verified, email send to owner?
  def verified
    @community = Community.find(params[:id]) 
    if current_user.admin? # only admin can mark house as verified
      @community.updated_by = current_user.id
      @community.verified = true
      if @community.save
        flash[:house] = "Community is been successfully verified!"
        @manager = @community.manager
        if !@manager.nil?
          #send email to community manager, also create notification  
          UserMailer.community_verified(@community, @manager).deliver_now #deliver_later  
        end
        render 'show', :status => :ok
      else
        @errMsg = @community.errors.full_messages
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
    @community = Community.find(params[:id])
    if current_user.admin? || current_user.owner?(@community) # only house owner or admin can create
      @community.deactivate! 
      render 'destroy', :status => :ok
    else
      @errMsg = "User is neither admin nor house owner."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def search
    print "user wants to search community here."
    communities = Community.arel_table
    @communities = if params[:address]
                 Community.where(communities[:addr1].matches("%#{params[:address]}%")
                                          .or(communities[:addr2].matches("%#{params[:address]}%"))
                                          .or(communities[:addr3].matches("%#{params[:address]}%"))
                                          .or(communities[:addr4].matches("%#{params[:address]}%"))
                                          .or(communities[:name].matches("%#{params[:address]}%"))
                                          )
              else 
                 []
               end
  end

end
