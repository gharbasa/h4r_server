class House < ActiveRecord::Base
  attr_accessible :name, :addr1, :addr2, :addr3, :addr4, :no_of_portions, :no_of_floors, 
                  :total_pics, :processing_fee, :verified,:active, :is_open,
                  :created_by,:updated_by, :created_at, :updated_at, :community_id, :description,
                  :no_of_bedrooms, :no_of_bathrooms, :floor_number, :search, :account_id
  
  belongs_to :community
  belongs_to :account
  has_many :house_pics #, dependent: :destroy
  has_many :user_house_links
  has_many :house_notes
  has_many :users, through: :user_house_links
  has_many :user_house_contracts
  
  scope :search, lambda { |keyword| where("active=1 and search like ?", '%' + keyword.upcase + '%') }
  
  #TODO: Post create, user who creates the house will be by default the owner, later can be changed to different user.
  include ActiveFlag
  TOKEN = " ^ "
  module VERIFICATION
    NOT_VERIFIED = 0
    VERIFIED = 1
  end           
  
  def prepareSearchString
    searchString = (name.presence || "") + TOKEN + 
          (addr1.presence || "") + TOKEN + 
          (addr2.presence || "") + TOKEN + 
          (addr3.presence || "") + TOKEN + 
          (addr4.presence || "") + TOKEN + 
          (description.presence || "")  + TOKEN + communityName 
          
    house_pics.each do |house_pic|
      searchString = searchString + TOKEN + (house_pic.rekognition_labels.presence || "")  if !house_pic.rekognition_labels.nil?
      searchString = searchString + TOKEN + (house_pic.rekognition_text.presence || "")  if !house_pic.rekognition_text.nil?
    end
    searchString.truncate(2000).upcase
  end
  
  def cloudsearch_json
      
      address = (addr1.presence || "") + TOKEN +
                          (addr2.presence || "") + TOKEN +
                          (addr3.presence || "") + TOKEN +
                          (addr4.presence || "")
      fields = {}
      fields["active"] = active
      fields["address"] = address
      fields["address1"] = addr1.presence || ""
      fields["address2"] = addr2.presence || ""
      fields["address3"] = addr3.presence || ""
      fields["address4"] = addr4.presence || ""
      fields["community"] = communityName
      fields["community_id"] = community_id.presence || ""
      fields["created_at"] = created_at
      fields["description"] = description.presence || ""
      fields["floor_number"] = floor_number
      fields["is_open"] = is_open
      fields["name"] = (name.presence || "")
      fields["no_of_bathrooms"] = no_of_bathrooms
      fields["no_of_bedrooms"] = no_of_bedrooms
      fields["no_of_floors"] = no_of_floors
      fields["no_of_pics"] = no_of_pics
      fields["no_of_portions"] = no_of_portions
      fields["processing_fee"] = processing_fee
      fields["updated_at"] = updated_at
      fields["verified"] = verified
      
      #fields["houseid"] = id
      rekognition_labels = []
      house_pics.each do |house_pic|
        rekognition_labels.push(house_pic.rekognition_text.presence || "") if !house_pic.rekognition_text.nil? 
      end
      fields["rekognition_labels"] = rekognition_labels
      
      data = {}
      data["type"] = "add"
      data["id"] = id
      data["fields"] = fields
      [data]
  end
  
  def guest
    user_obj = nil
    user_house_links.each do |link|
      if link.guest? && (user_obj.nil?)
        user_obj = link.user
      end
    end
    user_obj
  end
  
  def tenant
    user_obj = nil
    user_house_links.each do |link|
      if link.tenant? && (user_obj.nil?)
        user_obj = link.user
      end
    end
    user_obj
  end
  
  def land_lord
    user_obj = nil
    user_house_links.each do |link|
      if link.land_lord? && (user_obj.nil?)
        user_obj = link.user
      end
    end
    user_obj
  end
  
  def accountant
    user_obj = nil
    user_house_links.each do |link|
      if link.accountant? && (user_obj.nil?)
        user_obj = link.user
      end
    end
    user_obj
  end
  
  def property_mgmt_mgr
    user_obj = nil
    user_house_links.each do |link|
      if link.property_mgmt_mgr? && (user_obj.nil?)
        user_obj = link.user
      end
    end
    user_obj
  end
  
  def property_mgmt_emp
    user_obj = nil
    user_house_links.each do |link|
      if link.property_mgmt_emp? && (user_obj.nil?)
        user_obj = link.user
      end
    end
    user_obj
  end
  
  def agency_collection_emp
    user_obj = nil
    user_house_links.each do |link|
      if link.agency_collection_emp? && (user_obj.nil?)
        user_obj = link.user
      end
    end
    user_obj
  end
  
  def agency_collection_mgr
    user_obj = nil
    user_house_links.each do |link|
      if link.agency_collection_mgr? && (user_obj.nil?)
        user_obj = link.user
      end
    end
    user_obj
  end
  
  def maintenance
    user_obj = nil
    user_house_links.each do |link|
      if link.maintenance? && (user_obj.nil?)
        user_obj = link.user
      end
    end
    user_obj
  end
  
  def verified?
    verified == VERIFICATION::VERIFIED
  end
  
  def deactivate!
    self.active = false
    save
  end
  
  def activeTenantContractsExists?
    user_house_contract_obj = nil
    user_house_contracts.each do |user_house_contract|
      user_house_contract_obj = user_house_contract if ((user_house_contract.active == true) && (user_house_contract.tenant?))
    end
    user_house_contract_obj
  end
  
  def no_of_pics
    house_pics.count 
  end
  
  def communityName
    commName = ""
    commName = community.name if !community.nil?
    commName
  end
end