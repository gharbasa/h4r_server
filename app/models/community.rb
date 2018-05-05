class Community < ActiveRecord::Base
  attr_accessible  :name, :addr1, :addr2, :addr3, :addr4, :total_pics, :processing_fee,
                                :verified, :active, :created_at, :updated_at,
                                :created_by, :updated_by, :manager_id
                  
  has_many :houses #houes in the community
  has_many :community_pics
  has_many :users  #community users
  belongs_to :manager, class_name: "User"
  belongs_to :createdBy, class_name: "User",foreign_key: "created_by"
  #TODO: Post create, user who creates the house will be by default the owner, later can be changed to different user.
  include ActiveFlag
  
  module VERIFICATION
    NOT_VERIFIED = 0
    VERIFIED = 1
  end           
  
  def owner
    house_owner = nil
    user_house_links.each do |link|
      link.owner?
      house_owner = link.user
    end
    house_owner
  end
  
  def verified?
    verified == VERIFICATION::VERIFIED
  end
  
  def deactivate!
    self.active = false
    save
  end
  
  def unitsCount
    houses.count
  end
  
  def openUnits
    count = 0
    houses.each do |house|
      count = count+1 if house.is_open == true
    end
    count
  end
  
end