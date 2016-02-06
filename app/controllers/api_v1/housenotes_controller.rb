class ApiV1::HousenotesController < ApiV1::BaseController
  before_filter :require_user, :only => [:index, :show, :create, :update, :destroy]
  skip_before_action :verify_authenticity_token
  before_filter :load_house, :only => [:index, :show, :destroy, :create]
  
  def index
    if(@house)
       @notes = @house.house_notes
    else
      @errMsg = "House not found."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def create
      if(@house)  
        @note = HouseNote.create(:house_id => @house.id,
                                  :note => params[:note],
                                  :created_by => current_user.id,
                                  :private => params[:private]
                                  )
        if(@note.save)
          render 'show', :status => :created  
        else 
          @errMsg = @house.errors.full_messages
          print @errMsg 
          render 'error', :status => :unprocessable_entity  
        end
      else
        @errMsg = "House not found."
        print @errMsg 
        render 'error', :status => :unprocessable_entity
      end
  end
 
  def show
    
  end

  def destroy
    @housenote = HouseNote.find(params[:id])
    if current_user.admin? || current_user.owner?(@house) # only house owner or admin can create
      @housenote.delete 
      render 'destroy', :status => :ok
    else
      @errMsg = "User is neither admin nor house owner."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def load_house
    house_id = params[:house_id]
    if house_id
      @house = House.find(house_id)
    end
  end
end
