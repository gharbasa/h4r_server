class Account < ActiveRecord::Base
  attr_accessible  :baseline_amt, :baseline_date, :house_id, :note,
                                :active, :created_at, :updated_at,
                                :created_by, :updated_by, :description

  has_many :houses
  has_many :account_markings
  belongs_to :createdBy, class_name: "User",foreign_key: "created_by"
  include ActiveFlag
  
  def deactivate!
    self.active = false
    save
  end
  
  def baselineDate
    baseline_date.to_s(:custom_datetime)
  end

  def unitsCount
    houses.count
  end
  
  def netAmount
    totalAmount = baseline_amt
    logger.info("Account =" + note + "(" + id.to_s + ")" + " Baseline Amount=" + totalAmount.to_s + " as of date=" + baselineDate)
    houses.each do |house|
      house.user_house_contracts.each do |user_house_contract|
        payments = user_house_contract.payments.active.afterDate(baseline_date)
        payments.each do |payment| #receivables/payments after account.baseline_date
          if(user_house_contract.isIncomeContract)
            logger.info("Adding income=" + payment.amount.to_s + " of dated=" + payment.paymentDate)
            totalAmount = totalAmount + payment.amount
          else
            logger.info("Adding expediture=" + payment.amount.to_s + " of dated=" + payment.paymentDate) 
            totalAmount = totalAmount - payment.amount
          end
        end
      end 
    end
    totalAmount
  end

end