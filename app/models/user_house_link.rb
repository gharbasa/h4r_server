class UserHouseLink < ActiveRecord::Base
  
  attr_accessible :user_id, :house_id, :role, :processing_fee, :total_renewals, :total_pending_payments, 
                  :total_fail_payments, :total_success_payments, :user_house_contract_id , :active,  
                  :created_by, :updated_by
  
  belongs_to :user
  belongs_to :house
  has_many :user_house_contracts #, dependent: :destroy
  
  include ActiveFlag
  
  def tenant?
    role == User::USER_ACL::TENANT 
  end
  
  def owner?
    role == User::USER_ACL::LAND_LORD
  end

end