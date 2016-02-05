class HouseNote < ActiveRecord::Base
  attr_accessible :note, :active, 
                  :created_by,:updated_by, :created_at, :updated_at,
                  :house_id
  belongs_to :house
  
  def deactivate!
    self.active = false
    save
  end  
end