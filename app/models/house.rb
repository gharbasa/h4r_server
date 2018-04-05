class House < ActiveRecord::Base
  attr_accessible :name, :addr1, :addr2, :addr3, :addr4, :no_of_portions, :no_of_floors, 
                  :total_pics, :processing_fee, :verified,:active, 
                  :created_by,:updated_by, :created_at, :updated_at, :community_id, :description
                  
  belongs_to :community
  has_many :house_pics #, dependent: :destroy
  has_many :user_house_links
  has_many :house_notes
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
      if link.owner? && (house_owner.nil?)
        house_owner = link.user
      end
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
  
  #Non-house owner can only view public and his created notes.
  def public_and_own_house_notes user
    public_house_notes = []
    house_notes.each do |house_note|
      if !(house_note.private) || (user.id == house_note.created_by) 
        public_house_notes.push(house_note)
      end
    end
    public_house_notes
  end
end