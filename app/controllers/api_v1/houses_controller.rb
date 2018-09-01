class ApiV1::HousesController < ApiV1::BaseController
  before_filter :require_user, :only => [:index, :show, :create, :update, :destroy, 
                                  :verified, :notverified, :notes, :create_note, :makeitOpen, :makeitClosed,
                                  :activate, :inactivate, :list4Reports]
  skip_before_action :verify_authenticity_token
  before_filter :load_user, :only => [:index]
  
  def index
    if(params[:community_id].nil?)
      if(@user)
         #@UserHouseLinks = UserHouseLink.where(:user => @user)#House.where(:user_house_links.user => @user)
         @houses = @user.houses.order(name: :asc)
      else
        @houses = House.all.order(name: :asc)
      end
    else
      community = Community.find(params[:community_id])
      @houses = community.houses
    end
  end
  
  def list4Reports
      if current_user.admin?
        index
      else
        @houses = House.joins(:user_house_links).merge(UserHouseLink.notTenantOnlyHouseLinks(current_user.id))   
      end
  end
  
  def create
    params[:house][:created_by] = current_user.id
     
    if(params[:house][:name].nil? || params[:house][:name] == "") 
      @errMsg = 'House name can not be empty'
      print @errMsg 
      render 'error', :status => :unprocessable_entity
      return
    end
    @house = House.create(params[:house])
    @house.verified = false
    if @house.save
      searchString = @house.prepareSearchString
      @house.update_attributes(:search => searchString)
      render 'show', :status => :created
    else
      @errMsg = @house.errors.full_messages
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def show
    @house = House.find(params[:id])
  end

  def contracts
    @house = House.find(params[:id])
    @user_house_contracts = @house.user_house_contracts
  end
  
  def update
    @house = House.find(params[:id]) 
    if isAuth @house  # only house owner or admin can update
      @house.updated_by = current_user.id
      params[:house][:search] = @house.prepareSearchString
      if @house.update_attributes(params[:house])
        flash[:house] = "House updated!"
        render 'show', :status => :ok
      else
        @errMsg = @house.errors.full_messages
        print @errMsg
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is neither admin nor house land_lord."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  #To mark that the house is verified, email send to owner?
  def verified
    @house = House.find(params[:id]) 
    if current_user.admin? # only admin can mark house as verified
      @house.updated_by = current_user.id
      @house.verified = true
      if @house.save
        flash[:house] = "House has been successfully verified!"
        @owner = @house.land_lord
        if !@owner.nil?
          #send email to house owner  
          UserMailer.house_verified(@house, @owner).deliver_now #deliver_later  
        end
        render 'show', :status => :ok
      else
        @errMsg = @house.errors.full_messages
        print @errMsg 
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is not admin."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  #To mark that the house is verified, email send to owner?
  def notverified
    @house = House.find(params[:id]) 
    if current_user.admin? # only admin can mark house as verified
      @house.updated_by = current_user.id
      @house.verified = false
      if @house.save
        flash[:house] = "House has been successfully set to Not verified!"
        @owner = @house.land_lord
        if !@owner.nil?
          #send email to house owner  
          #UserMailer.house_verified(@house, @owner).deliver_now #deliver_later  
        end
        render 'show', :status => :ok
      else
        @errMsg = @house.errors.full_messages
        print @errMsg 
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is not admin."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  #To mark that the house is inactivated, email send to owner?
  def inactivate
    @house = House.find(params[:id]) 
    if isAuth @house  # only house owner or admin can update
      @house.updated_by = current_user.id
      @house.active = false
      if @house.save
        flash[:house] = "House has been successfully inactivated!"
        #@owner = @house.owner
        #if !@owner.nil?
        #  #send email to house owner  
        #  UserMailer.house_verified(@house, @owner).deliver_now #deliver_later  
        #end
        render 'show', :status => :ok
      else
        @errMsg = @house.errors.full_messages
        print @errMsg 
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is not the owner of the house."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  #To mark that the house is inactivated, email send to owner?
  def activate
    @house = House.find(params[:id]) 
    if isAuth @house  # only house owner or admin can update
      @house.updated_by = current_user.id
      @house.active = true
      if @house.save
        flash[:house] = "House has been successfully activated!"
        #@owner = @house.owner
        #if !@owner.nil?
        #  #send email to house owner  
        #  UserMailer.house_verified(@house, @owner).deliver_now #deliver_later  
        #end
        render 'show', :status => :ok
      else
        @errMsg = @house.errors.full_messages
        print @errMsg 
        render 'error', :status => :unprocessable_entity
      end
    else
      @errMsg = "User is not the owner of the house."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  #To mark that the house is open, it is ready for renting
  def makeitOpen
    @house = House.find(params[:id])
    if !isAuth(@house)  # only house owner or admin can update
      @errMsg = "User is not authorized to update house details."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
      return
    end
    
    user_house_contract = @house.activeTenantContractsExists?  
    if(!user_house_contract.nil?)
      @errMsg = "'" + @house.name  + "' has an active tenant contract with user '" + user_house_contract.user.fullName + "', can not make it open."
      print @errMsg 
      render 'error', :status => :unprocessable_entity   
      return
    end
    
    @house.updated_by = current_user.id
    @house.is_open = true
    if @house.save
      flash[:house] = "House has been successfully made it open!"
      #@owner = @house.owner
      #if !@owner.nil?
      #  #send email to house owner  
      #  UserMailer.house_verified(@house, @owner).deliver_now #deliver_later  
      #end
      render 'show', :status => :ok
    else
      @errMsg = @house.errors.full_messages
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  #To mark that the house is closed, not ready for rent
  def makeitClosed
    @house = House.find(params[:id])
    if !isAuth(@house)  # only house owner or admin can update
      @errMsg = "User is not authorized to update house details."
      print @errMsg 
      render 'error', :status => :unprocessable_entity   
      return
    end
    
    @house.updated_by = current_user.id
    @house.is_open = false
    if @house.save
      flash[:house] = "House has been successfully made it closed!"
      
      #@owner = @house.owner
      #if !@owner.nil?
      #  #send email to house owner  
      #  UserMailer.house_verified(@house, @owner).deliver_now #deliver_later  
      #end
      render 'show', :status => :ok
    else
      @errMsg = @house.errors.full_messages
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def destroy
    @house = House.find(params[:id])
    if current_user.admin? || current_user.land_lord?(@house) # only house owner or admin can create
      @house.deactivate! 
      render 'destroy', :status => :ok
    else
      @errMsg = "User is neither admin nor house owner."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def search
    print "user wants to search houses here."
    #houses = House.arel_table
    
    #@houses = if params[:address]
    #             House.where(houses[:addr1].matches("%#{params[:address]}%")
    #                                      .or(houses[:addr2].matches("%#{params[:address]}%"))
    #                                      .or(houses[:addr3].matches("%#{params[:address]}%"))
    #                                      .or(houses[:addr4].matches("%#{params[:address]}%"))
    #                                      .or(houses[:name].matches("%#{params[:address]}%"))
    #                                      )
    #          else 
    #             []
    #           end
    
    @houses = if params[:search] && !params[:search].empty?
                House.search(params[:search])
              else
                []
              end
  end
  
  def cloudsearch
    #https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/CloudSearchDomain/Client.html#search-instance_method
    resp = Rails.configuration.awsCSDomainClientForSearch.search({query: params[:search] ,
                                                                  return: "_all_fields",
                                                                  sort: "name asc, updated_at desc",
                                                                  highlight:"{ \"name\": {\"format\": \"text\"},\"description\": {\"format\": \"text\"},\"address\": {\"format\": \"text\"}}",
                                                                  filter_query: "active:1", #Search for active houses only
                                                                  size: params[:pageSize],
                                                                  start:params[:pageNo],
                                                                  facet: "{ \"community_id\": {\"sort\": \"count\",\"size\":3}}"
                                                                  })
    houses = []
    print resp
    logger.info (resp)
    found = resp.hits.found
    #<struct Aws::CloudSearchDomain::Types::SearchResponse status=#<struct Aws::CloudSearchDomain::Types::SearchStatus timems=15, rid="2vHut84s2xcKqzEc">, hits=#<struct Aws::CloudSearchDomain::Types::Hits found=1, start=0, cursor=nil, hit=[#<struct Aws::CloudSearchDomain::Types::Hit id="1", fields={"updated_at"=>["2018-07-29T02:30:04.882Z"], "community"=>["Devanshire Hills"], "is_open"=>["0"], "no_of_bedrooms"=>["3"], "verified"=>["1"], "processing_fee"=>["2001.0"], "no_of_floors"=>["1"], "no_of_portions"=>["2"], "no_of_bathrooms"=>["2"], "description"=>["A very spacious gracious  whole hearted house A very spacious gracious d whole hearted house"], "address1"=>["22/Part, Vinayak Nagar"], "address2"=>["Yanamalakudur"], "address3"=>["500010"], "address4"=>["Andhra Pradesh, India"], "community_id"=>["1"], "floor_number"=>["1"], "address"=>["22/Part, Vinayak Nagar ^ Yanamalakudur ^ 500010 ^ Andhra Pradesh, India"], "active"=>["1"], "name"=>["Ali Manzil"], "created_at"=>["2016-01-31T02:09:38Z"], "rekognition_labels"=>["J1 Handnriten|fonts|YOU CAN DOWNLOAD AND USE|FOR FREE|J1|Handnriten|fonts|YOU|CAN|DOWNLOAD|AND|USE|FOR|FREE|", "Test Your Reactions!|Click on the squares and circles as quickly as you can!!|Your time: 0.982s|Test|Your|Reactions!|Click|on|the|squares|and|circles|as|quickly|as|you|can!!|Your|time:|0.982s|"], "no_of_pics"=>["2"]}, exprs=nil, highlights={"name"=>"*Ali* Manzil", "description"=>"A very spacious gracious  whole hearted house A very spacious gracious d whole hearted house", "address"=>"22/Part, Vinayak Nagar ^ Yanamalakudur ^ 500010 ^ Andhra Pradesh, India"}>]>, facets={"community_id"=>#<struct Aws::CloudSearchDomain::Types::BucketInfo buckets=[#<struct Aws::CloudSearchDomain::Types::Bucket value="1", count=1>]>}, stats=nil>
    resp.hits.hit.each do |house|
      communitName = ""
      communitName = house.fields['community'][0] if house.fields['community_id'][0] != "0" 
      houses.push({:id => house.id, 
                    :name => house.fields['name'][0],
                    :addr1 => house.fields['address1'][0],
                    :addr2 => house.fields['address2'][0],
                    :addr3 => house.fields['address3'][0],
                    :addr4 => house.fields['address4'][0],
                    :no_of_portions => house.fields['no_of_portions'][0],
                    :no_of_floors => house.fields['no_of_floors'][0],
                    :verified => house.fields['verified'][0] == "0"?false:true,
                    :processing_fee => house.fields['processing_fee'][0],
                    :community_id => house.fields['community_id'][0],
                    :active => house.fields['active'][0] == "0"?false:true,
                    :created_at => house.fields['created_at'][0],
                    :updated_at => house.fields['updated_at'][0],
                    :description => house.fields['description'][0],
                    :is_open => house.fields['is_open'][0] == "0"?false:true,
                    :no_of_bedrooms => house.fields['no_of_bedrooms'][0],
                    :no_of_bathrooms => house.fields['no_of_bathrooms'][0],
                    :floor_number => house.fields['floor_number'][0],
                    :no_of_pics => house.fields['no_of_pics'][0],
                    #:account_id => house.fields['account_id'][0],
                    :communityName => communitName 
                  })
    end
    @searchResults = OpenStruct.new({:found => found, :results => houses})
    #@houses = House.find_all_by_id( houseids )
  end
  
  def load_user
    user_id = params[:user_id]
    if user_id
      @user = User.find(user_id)
    end
  end
  
  def isAuth house  # only house owner or admin can update house
    current_user.admin? || !current_user.tenantOnly?(house)
  end
end
