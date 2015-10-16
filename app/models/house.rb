class House < ActiveRecord::Base
  attr_accessible :name, :addr1, :addr2, :addr3, :addr4, :no_of_portions, :no_of_floors, 
                  :total_pics, :processing_fee, :verified, 
                  :created_by,:updated_by, :created_at, :updated_at
                  
  #belongs_to :notification_type
  has_many :house_pics #, dependent: :destroy
  has_many :user_house_links
  has_many :users, through: :user_house_links
  
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

end