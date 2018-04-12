class HouseNote < ActiveRecord::Base
  attr_accessible :note, :active, 
                  :created_by,:updated_by, :created_at, :updated_at,
                  :house_id, :private
  alias_attribute :private_note, :private
  belongs_to :house
  include DatetimeFormat
    
  def deactivate!
    self.active = false
    save
  end  
end