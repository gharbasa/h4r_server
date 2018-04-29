class House < ActiveRecord::Base
  attr_accessible :name, :addr1, :addr2, :addr3, :addr4, :no_of_portions, :no_of_floors, 
                  :total_pics, :processing_fee, :verified,:active, :is_open,
                  :created_by,:updated_by, :created_at, :updated_at, :community_id, :description,
                  :no_of_bedrooms, :no_of_bathrooms, :floor_number

  belongs_to :community
  has_many :house_pics #, dependent: :destroy
  has_many :user_house_links
  has_many :house_notes
  has_many :users, through: :user_house_links
  has_many :user_house_contracts
  
  #TODO: Post create, user who creates the house will be by default the owner, later can be changed to different user.
  include ActiveFlag
  
  module VERIFICATION
    NOT_VERIFIED = 0
    VERIFIED = 1
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
  
  def activeContractsExists?
    user_house_contract_obj = nil
    user_house_contracts.each do |user_house_contract|
      user_house_contract_obj = user_house_contract if (user_house_contract.active == true)
    end
    user_house_contract_obj
  end
  
  #Non-house owner can only view public and his created notes.
  def public_and_own_house_notes user
    public_house_notes = []
    house_notes.order(created_at: :desc).each do |house_note|
      if !(house_note.private) || (user.id == house_note.created_by) 
        public_house_notes.push(house_note)
      end
    end
    public_house_notes
  end
end