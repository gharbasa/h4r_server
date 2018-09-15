class AccountMarking < ActiveRecord::Base
  attr_accessible  :amount, :marking_date, :account_id,
                                :active, :created_at, :updated_at,
                                :created_by, :updated_by

  has_many :accounts
  belongs_to :createdBy, class_name: "User",foreign_key: "created_by"
  include ActiveFlag
  
  def deactivate!
    self.active = false
    save
  end
  
  def markingDate
    marking_date.to_s(:custom_datetime)
  end
  
end
