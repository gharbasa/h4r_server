module DatetimeFormat 
    extend ActiveSupport::Concern

  def createdAt
       created_at.to_s(:custom_datetime)
  end
  def updateddAt
       updated_at.to_s(:custom_datetime)
  end
end