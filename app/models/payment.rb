class Payment < ActiveRecord::Base #This is actually the receivables.
  attr_accessible :user_house_contract_id, :payment, :payment_status, :payment_type,
                  :retries_count, :created_by, :updated_by, :note, :payment_date


  belongs_to :user_house_contract
  
  include ActiveFlag
  

  def deactivate!
    self.active = false
    save
  end
  def activate!
    self.active = true
    save
  end

end
