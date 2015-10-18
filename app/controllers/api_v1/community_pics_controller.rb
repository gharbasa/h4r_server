class ApiV1::CommunityPicsController < ApiV1::BaseController
  #before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:index, :show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token
  before_filter :load_community, :only => [:index]
  
  def index
    if(@community)
       @community_pics = @community.community_pics
    else
      @community_pics = CommunityPic.all
    end
  end
  
  def create
    if params[:community_pic][:created_by].nil?
       params[:community_pic][:created_by] = current_user.id
    end 
    
    if(params[:community_pic][:created_by] != current_user.id)
      @errMsg = "Login user is different from created_by user attribute in request payload."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
      return
    end
    
    processPicture if !params[:community_pic][:picture].nil?
    @community_pic = CommunityPic.create(params[:community_pic])
    @community_pic.created_by = (current_user == nil)? nil:current_user.id
    if canUserUpdate? @community_pic # only house owner or admin can upload pics
      if @community_pic.save
        #UserMailer.welcome_email(@user).deliver_now #deliver_later
        render 'show', :status => :created
      else
        @errMsg = @community_pic.errors.full_messages
        print @errMsg 
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is neither admin nor house owner"
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def show
    @community_pic = CommunityPic.find(params[:id])
  end

  def update
    @community_pic = CommunityPic.find(params[:id])
    @community = @community_pic.community
    if canUserUpdate? @community_pic # only house owner or admin can upload pics
      @community_pic.updated_by = current_user.id 
      processPicture if !params[:community_pic][:picture].nil?
      
      if @community_pic.update_attributes(params[:community_pic])
        flash[:notice] = "Community Pic Processed successfully!"
        render 'show', :status => :ok
      else
        @errMsg = @community_pic.errors.full_messages
        print @errMsg 
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is neither admin nor house owner"
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end

  
  def destroy
    @community_pic = CommunityPic.find(params[:id])
    @community = @community_pic.community
    if canUserUpdate? @community_pic # only house owner or admin can upload pics
      if @community_pic.destroy
        render 'destroy', :status => :ok
      else
        @errMsg = @community_pic.errors.full_messages
        print @errMsg 
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is neither admin nor house owner"
      print @errMsg 
      render 'error', :status => :unprocessable_entity    
    end
  end
  
  def canUserUpdate? community_pic
    current_user.admin? || current_user.manager?(community_pic.community) ||
            current_user.created?(community_pic.community)
  end
  
  def processPicture
    data = StringIO.new(Base64.decode64(params[:community_pic][:picture][:data]))
    data.class.class_eval { attr_accessor :original_filename, :content_type }
    data.original_filename = params[:community_pic][:picture][:filename]
    data.content_type = params[:community_pic][:picture][:content_type]
    params[:community_pic][:picture] = data
  end
  
  def load_community
    community_id = params[:community_id]
    if community_id
      @community = Community.find(community_id)
    end
  end
  
end
