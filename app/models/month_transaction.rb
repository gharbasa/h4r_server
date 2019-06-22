class MonthTransaction
  attr_accessor :paymentDate, :transType, :amount, :houseName, :description, :note
  
  def formattedPaymentDate
    paymentDate.to_s(:custom_datetime)
  end
  def transTypeStr
    return "Income" if transType == 1
    return "Expense" if transType == 2
  end
end