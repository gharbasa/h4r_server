class ApiV1::HouseContractNotesController < ApiV1::BaseController
  before_filter :require_user, :only => [:index, :show, :create, :update, :destroy]
  skip_before_action :verify_authenticity_token
  before_filter :load_houseContract, :only => [:index, :show, :destroy, :create]
  
  def index
    if(@houseContract)
        if(current_user.admin? || (current_user.land_lord? @house))
          @notes = @houseContract.house_contract_notes.order(created_at: :desc) #House owner can view all the house notes
        else
          @notes = HouseContractNote.non_private_by_user_contract(current_user.id, @houseContract.id)
        end
    else
      @errMsg = "House Contract Id not found."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def create
      if(@houseContract)  
        @note = HouseContractNote.create(:user_house_contract_id => @houseContract.id,
                                  :note => params[:note],
                                  :created_by => current_user.id,
                                  :private => params[:private_note]
                                  )
        if(@note.save)
          render 'show', :status => :created  
        else 
          @errMsg = @house.errors.full_messages
          print @errMsg 
          render 'error', :status => :unprocessable_entity  
        end
      else
        @errMsg = "houseContractNote not found."
        print @errMsg 
        render 'error', :status => :unprocessable_entity
      end
  end
 
  def show
    
  end

  def destroy
    @houseContractNote = HouseContractNote.find(params[:id])
    if current_user.admin? || current_user.land_lord?(@houseContractNote.user_house_contract.house) # only house owner or admin can create
      @houseContractNote.delete 
      render 'destroy', :status => :ok
    else
      @errMsg = "User is neither admin nor house owner."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def load_houseContract
    housecontract_id = params[:user_house_contract_id]
    if housecontract_id
      @houseContract = UserHouseContract.find(housecontract_id)
    end
  end
end
