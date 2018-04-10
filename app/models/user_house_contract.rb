class UserHouseContract < ActiveRecord::Base
  attr_accessible :user_id, :house_id, :contract_start_date, :user_house_link_id,
                  :contract_end_date, :annual_rent_amount, :monthly_rent_amount, :role, :active, :created_by, :updated_by, :note
                  
  belongs_to :user
  belongs_to :house
  belongs_to :user_house_link #This is not needed in the view.
  has_many :house_contract_notes 
  #TODO: Post create, user who creates the house will be by default the owner, later can be changed to different user.
  include ActiveFlag
  include AclCheckOnRole
  
  def deactivate!
    self.active = false
    save
  end
  def activate!
    self.active = true
    save
  end

  def contractStartDate
    contract_start_date.to_s(:custom_datetime)
  end
  
  def contractEndDate
    contract_end_date.to_s(:custom_datetime)
  end
  
end
