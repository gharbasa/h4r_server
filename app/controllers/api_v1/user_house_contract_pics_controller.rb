class ApiV1::UserHouseContractPicsController < ApiV1::BaseController
  #before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:index, :show, :edit, :update, :destroy, :create]
  skip_before_action :verify_authenticity_token
  before_filter :load_contract, :only => [:index, :show, :edit, :update, :destroy, :create]
  
  def index
    if(@contract)
       @contract_pics = @contract.user_house_contract_pics.order(created_at: :desc)
    else
      @contract_pics = UserHouseContractPic.all.order(created_at: :desc)
    end
  end
  
  def create
    params[:user_house_contract_pic][:created_by] = current_user.id
    if !canUserUpdate?
      @errMsg = "Login user is different from contract created user and not an admin user."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
      return
    end
    params[:user_house_contract_pic][:user_house_contract_id] = params[:user_house_contract_id]
    processPicture if !params[:user_house_contract_pic][:picture].nil?
    @contract_pic = UserHouseContractPic.create(params[:user_house_contract_pic])
    if @contract_pic.save
      #UserMailer.welcome_email(@user).deliver_now #deliver_later
      render 'show', :status => :created
    else
      @errMsg = @contract_pic.errors.full_messages
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def show
    @contract_pic = UserHouseContractPic.find(params[:id])
  end

  def update
    @contract_pic = UserHouseContractPic.find(params[:id])
    if canUserUpdate?
      @contract_pic.updated_by = current_user.id 
      processPicture if !params[:user_house_contract_pic][:picture].nil?
      params[:user_house_contract_pic][:user_house_contract_id] = params[:user_house_contract_id]
      if @contract_pic.update_attributes(params[:user_house_contract_pic])
        flash[:notice] = "House Pic Processed successfully!"
        render 'show', :status => :ok
      else
        @errMsg = @contract_pic.errors.full_messages
        print @errMsg 
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is neither admin nor creator of house contract"
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end

  
  def destroy
    @contract_pic = UserHouseContractPic.find(params[:id])
    if canUserUpdate?
      if @contract_pic.destroy
        render 'destroy', :status => :ok
      else
        @errMsg = @contract_pic.errors.full_messages
        print @errMsg 
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is neither admin nor contract creator"
      print @errMsg 
      render 'error', :status => :unprocessable_entity    
    end
  end
  
  def canUserUpdate?
    ((@contract.created_by == current_user.id) || (current_user.admin?))
  end
  
  def processPicture
    data = StringIO.new(Base64.decode64(params[:user_house_contract_pic][:picture][:data]))
    data.class.class_eval { attr_accessor :original_filename, :content_type }
    data.original_filename = params[:user_house_contract_pic][:picture][:filename]
    data.content_type = params[:user_house_contract_pic][:picture][:content_type]
    params[:user_house_contract_pic][:picture] = data
  end
  
  def load_contract
    print "ABEDDDD load contract " + params[:user_house_contract_id].to_s
    contract_id = params[:user_house_contract_id]
    if contract_id
      @contract = UserHouseContract.find(contract_id)
    end
  end

end
