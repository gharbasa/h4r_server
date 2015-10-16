class NotificationType < ActiveRecord::Base
  
  attr_accessible :ntype, :content, :require_retries, :active, :subject, :created_by, :updated_by
  has_many :notifications, dependent: :destroy
  
  
  module TYPES 
    NEW_USER        = 1
    HOUSE_VERIFIED = 2
    USER_HOUSE_RECORD_UPDATED = 3
  end
  
  include ActiveFlag
  
  def self.findNewUserWelcomeNotification 
    notificationtype = NotificationType.where(ntype: TYPES::NEW_USER, active: ActiveFlag::ACTIVE).take
  end
  
  def self.findHouseVerifiedNotification 
    notificationtype = NotificationType.where(ntype: TYPES::HOUSE_VERIFIED, active: ActiveFlag::ACTIVE).take
  end
  
  def self.findUserHouseLinkUpdate 
    notificationtype = NotificationType.where(ntype: TYPES::USER_HOUSE_RECORD_UPDATED, active: ActiveFlag::ACTIVE).take
  end
end