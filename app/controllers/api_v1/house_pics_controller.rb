class ApiV1::HousePicsController < ApiV1::BaseController
  #before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update, :destroy, :create]
  skip_before_action :verify_authenticity_token
  before_filter :load_house, :only => [:index, :create]
  
  def index
    if(@house)
       @house_pics = @house.house_pics.order(created_at: :desc)
    else
      @house_pics = HousePic.all.order(created_at: :desc)
    end
  end
  
  def create
     params[:house_pic][:created_by] = current_user.id
    
    if((@house.created_by != current_user.id) && !(current_user.admin?))
      @errMsg = "Login user is different from house created user and not an admin user."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
      return
    end
    imageData = StringIO.new(Base64.decode64(params[:house_pic][:picture][:data]))    
    processPicture if !params[:house_pic][:picture].nil?

    #Human-99, People-99, Person-99, Clothing-96, Sari-96, Racket-65, Chair-63, Furniture-63, Gown-57, Robe-57, Kindergarten-56, Costume-54, Baby-51, Child-51, Kid-51, Dress-50
    
    client = Aws::Rekognition::Client.new
    resp = client.detect_labels(
         image: { bytes: imageData}
    )
    
    resp.labels.each do |label|
      puts "#{label.name}-#{label.confidence.to_i}"
      if HousePic::HOUSE_PIC_SETTINGS::PROHIBITED_CONTENT[label.name] && label.confidence.to_i > HousePic::HOUSE_PIC_SETTINGS::PROHIBITED_CONTENT[label.name]
        @errMsg = "Hey there is prohibited content in the image(#{label.name}-#{label.confidence.to_i})."
        puts @errMsg
        render 'error', :status => :unprocessable_entity
        return
      end
    end


    @house_pic = HousePic.create(params[:house_pic])
    @house_pic.created_by = (current_user == nil)? nil:current_user.id
    
    if current_user.admin? || current_user.land_lord?(@house) # only house owner or admin can upload pics
      
      if @house_pic.save
        #UserMailer.welcome_email(@user).deliver_now #deliver_later
        render 'show', :status => :created
      else
        @errMsg = @house_pic.errors.full_messages
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
    @house_pic = HousePic.find(params[:id])
  end

  def update
    @house_pic = HousePic.find(params[:id])
    if canUserUpdate? @house_pic # only house owner or admin can upload pics
      @house_pic.updated_by = current_user.id 
      processPicture if !params[:house_pic][:picture].nil?
      
      if @house_pic.update_attributes(params[:house_pic])
        flash[:notice] = "House Pic Processed successfully!"
        render 'show', :status => :ok
      else
        @errMsg = @house_pic.errors.full_messages
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
    @house_pic = HousePic.find(params[:id])
    if canUserUpdate? @house_pic # only house owner or admin can upload pics
      if @house_pic.destroy
        render 'destroy', :status => :ok
      else
        @errMsg = @house_pic.errors.full_messages
        print @errMsg 
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is neither admin nor house owner"
      print @errMsg 
      render 'error', :status => :unprocessable_entity    
    end
  end
  
  def canUserUpdate? house_pic
    current_user.admin? || current_user.land_lord?(house_pic.house)
  end
  
  def processPicture
    data = StringIO.new(Base64.decode64(params[:house_pic][:picture][:data]))
    data.class.class_eval { attr_accessor :original_filename, :content_type }
    data.original_filename = params[:house_pic][:picture][:filename]
    data.content_type = params[:house_pic][:picture][:content_type]
    params[:house_pic][:picture] = data
  end
  
  def load_house
    house_id = params[:house_id]
    if house_id
      @house = House.find(house_id)
    end
  end

end
