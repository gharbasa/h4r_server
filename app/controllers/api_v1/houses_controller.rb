class ApiV1::HousesController < ApiV1::BaseController
  before_filter :require_user, :only => [:index, :show, :create, :update, :destroy, :search, :verified]
  skip_before_action :verify_authenticity_token
  before_filter :load_user, :only => [:index]
  
  def index
    if(@user)
       #@UserHouseLinks = UserHouseLink.where(:user => @user)#House.where(:user_house_links.user => @user)
       @houses = @user.houses
    else
      @houses = House.all
    end
  end
  
  def create
    if(params[:house][:created_by] != current_user.id)
      puts "Login user is different from created_by user attribute in request payload."
      render 'errors', :status => :unprocessable_entity
      return
    end

    @house = House.create(params[:house])
    #@house.created_by = current_user.id
    @house.verified = false
    if @house.save
      render 'show', :status => :created
    else
      print @house.errors.full_messages
      render 'errors', :status => :unprocessable_entity
    end
  end
  
  def show
    @house = House.find(params[:id])
  end

  def update
    @house = House.find(params[:id]) 
    if current_user.admin? || current_user.owner?(@house) # only house owner or admin can create
      @house.updated_by = current_user.id
      if @house.update_attributes(params[:house])
        flash[:house] = "House updated!"
        render 'show', :status => :ok
      else
        print @house.errors.full_messages
        render 'errors', :status => :unprocessable_entity
      end
    else
      puts "User is neither admin nor house owner."
      render 'errors', :status => :unprocessable_entity
    end
  end
  
  #To mark that the house is verified, email send to owner?
  def verified
    @house = House.find(params[:id]) 
    if current_user.admin? # only admin can mark house as verified
      @house.updated_by = current_user.id
      @house.verified = true
      if @house.save
        flash[:house] = "House is been successfully verified!"
        @owner = @house.owner
        if !@owner.nil?
          #send email to house owner  
          UserMailer.house_verified(@house, @owner).deliver_now #deliver_later  
        end
        render 'show', :status => :ok
      else
        print @house.errors.full_messages
        render 'errors', :status => :unprocessable_entity
      end
    else
      puts "User is not admin."
      render 'errors', :status => :unprocessable_entity
    end
  end
  
  def destroy
    @house = House.find(params[:id])
    if current_user.admin? || current_user.owner?(@house) # only house owner or admin can create
      @house.deactivate! 
      render 'destroy', :status => :ok
    else
      puts "User is neither admin nor house owner."
      render 'errors', :status => :unprocessable_entity
    end
  end
  
  def search
    print "user wants to search houses here."
    houses = House.arel_table
    @houses = if params[:address]
                 House.where(houses[:addr1].matches("%#{params[:address]}%")
                                          .or(houses[:addr2].matches("%#{params[:address]}%"))
                                          .or(houses[:addr3].matches("%#{params[:address]}%"))
                                          .or(houses[:addr4].matches("%#{params[:address]}%"))
                                          )
              else 
                 []
               end
  end
  
  def load_user
    user_id = params[:user_id]
    if user_id
      @user = User.find(user_id)
    end
  end
end
