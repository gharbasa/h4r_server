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
    communityName = ""
    communityName = community.name if !community.nil?
    searchString = ((name.presence || "") + TOKEN + 
          (addr1.presence || "") + TOKEN + 
          (addr2.presence || "") + TOKEN + 
          (addr3.presence || "") + TOKEN + 
          (addr4.presence || "") + TOKEN + 
          (description.presence || "")  + TOKEN + 
          (communityName.presence || ""))
          
    house_pics.each do |house_pic|
      searchString = searchString + TOKEN + (house_pic.rekognition_labels.presence || "")  if !house_pic.rekognition_labels.nil?
      searchString = searchString + TOKEN + (house_pic.rekognition_text.presence || "")  if !house_pic.rekognition_text.nil?
    end
    searchString.truncate(2000).upcase
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
end