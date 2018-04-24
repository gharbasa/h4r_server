class Payment < ActiveRecord::Base #This is actually $$$ receivables.
  attr_accessible :user_house_contract_id, :payment, :payment_status, :payment_type,
                  :retries_count, :created_by, :updated_by, :note, :payment_date, :active


  belongs_to :user_house_contract
  
  include ActiveFlag
  include DatetimeFormat

  def deactivate!
    self.active = false
    save
  end
  def activate!
    self.active = true
    save
  end
  
  def paymentDate
    payment_date.to_s(:custom_datetime)
  end
  
  def paymentMonth
    payment_date.strftime('%b') #%m
  end
  
  def paymentYear
    payment_date.year  
  end
end
