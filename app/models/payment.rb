#This can be either Paymnet for the work contract (or) rent receivable.
class Payment < ActiveRecord::Base #This is actually $$$ receivables.
  attr_accessible :user_house_contract_id, :amount, :payment_status, :payment_type,
                  :retries_count, :created_by, :updated_by, :note, :payment_date, :active


  belongs_to :user_house_contract
  scope :active, lambda { where(:active => 1) }
  scope :afterDate, lambda { |payment_date| where("payment_date > ?", payment_date) }
  scope :betweenDates, lambda {|start_date, end_date| where(:payment_date => start_date.beginning_of_day..end_date.end_of_day)}
  scope :betweenReceivedDates, lambda {|start_date, end_date| where(:updated_at => start_date.beginning_of_day..end_date.end_of_day)}
  scope :inContracts, lambda { |contracts| where(:user_house_contract => contracts) }
  
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
