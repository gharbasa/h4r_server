class Notification < ActiveRecord::Base
  
  attr_accessible :user_id, :notification_type_id, :retries_count, 
                  :active, :created_by, :updated_by, :priority
  
  belongs_to :notification_type
  belongs_to :user
  include ActiveFlag
  
  module PRIORITY
    HIGH         = 1 << 1 
    MEDIUM       = 1 << 2
    NORMAL       = 1 << 3
  end
  
  def priorityHigh?
    priority == PRIORITY::HIGHT?
  end
  
  def priorityMedium?
    priority == PRIORITY::MEDIUM?
  end
  
  def priorityNormal?
    priority == PRIORITY::NORMAL?
  end
  
  #attr_accessor :notification_type, :user
   
  def deactivate!
    self.active = false
    save
  end
end