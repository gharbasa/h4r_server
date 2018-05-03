class HouseNote < ActiveRecord::Base
  attr_accessible :note, :active, 
                  :created_by,:updated_by, :created_at, :updated_at,
                  :house_id, :private
  alias_attribute :private_note, :private
  belongs_to :house
  include DatetimeFormat
  scope :non_private_by_house_user, lambda { |user_id, house_id| where("(private != 1 or created_by=?) and house_id=?", user_id, house_id) }
  
  def deactivate!
    self.active = false
    save
  end  
end