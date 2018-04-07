class UserHouseLink < ActiveRecord::Base
  
  attr_accessible :user_id, :house_id, :role, :processing_fee, :total_renewals, :total_pending_payments, 
                  :total_fail_payments, :total_success_payments, :user_house_contract_id , :active,  
                  :created_by, :updated_by
  
  belongs_to :user
  belongs_to :house
  has_many :user_house_contracts #, dependent: :destroy
  
  include ActiveFlag

  def guest?
    (role &  User::USER_ACL::GUEST) ==  User::USER_ACL::GUEST
  end
  
  def tenant?
    (role &  User::USER_ACL::TENANT) ==  User::USER_ACL::TENANT
  end
  
  def land_lord?
    (role &  User::USER_ACL::LAND_LORD) ==  User::USER_ACL::LAND_LORD
  end
  
  def accountant?
    (role &  User::USER_ACL::ACCOUNTANT) ==  User::USER_ACL::ACCOUNTANT
  end
  
  def property_mgmt_mgr?
    (role &  User::USER_ACL::PROPERTY_MGMT_MGR) ==  User::USER_ACL::PROPERTY_MGMT_MGR
  end
  
  def property_mgmt_emp?
    (role &  User::USER_ACL::PROPERTY_MGMT_EMP) ==  User::USER_ACL::PROPERTY_MGMT_EMP
  end
  
  def agency_collection_emp?
    (role &  User::USER_ACL::AGENCY_COLLECTION_EMP) ==  User::USER_ACL::AGENCY_COLLECTION_EMP
  end
  
  def agency_collection_mgr?
    (role &  User::USER_ACL::AGENCY_COLLECTION_MGR) ==  User::USER_ACL::AGENCY_COLLECTION_MGR
  end
  
end