class UserHouseContract < ActiveRecord::Base
  attr_accessible :user_house_link_id, :contract_start_date, 
                  :contract_end_date, :rent_amount, :active, :created_by, :updated_by
                  
  belongs_to :user_house_link
  
  #TODO: Post create, user who creates the house will be by default the owner, later can be changed to different user.
  include ActiveFlag
  
  def deactivate!
    self.active = false
    save
  end

end