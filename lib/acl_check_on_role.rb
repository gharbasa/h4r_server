module AclCheckOnRole
    extend ActiveSupport::Concern 
   
   included do

   end
   
   module USER_ACL
    GUEST                 = 0 #default
    ADMIN                 = 1 << 16 #65536, 100000000
    TENANT                = 1 << 15 #32768, 010000000
    LAND_LORD             = 1 << 14 #16384, 001000000
    ACCOUNTANT            = 1 << 13 #8192
    PROPERTY_MGMT_MGR     = 1 << 12 #4096 Property management manager
    PROPERTY_MGMT_EMP     = 1 << 11 #2048 Property management employee
    AGENCY_COLLECTION_EMP = 1 << 10 #1024 Collection agency emp
    AGENCY_COLLECTION_MGR = 1 << 9 #512 Collection agency mgr
    MAINTENANCE           = 1 << 8 #256 Mainenance Contractor
    #User can create these many types of contracts
    #=49408,1100001100000000
    DEFAULT_ENTITLEMENT = TENANT + LAND_LORD + MAINTENANCE + AGENCY_COLLECTION_MGR
  end
  
  def maintenance?
    (role & USER_ACL::MAINTENANCE) == USER_ACL::MAINTENANCE
  end
  
  def admin?
    #print "Lets check if the user is admin=" + role.to_s + "," + (role & USER_ACL::ADMIN).to_s
    (role & USER_ACL::ADMIN) == USER_ACL::ADMIN
  end

  def guest?
    (role &  USER_ACL::GUEST) ==  USER_ACL::GUEST
  end
  
  def tenant?
    (role &  USER_ACL::TENANT) ==  USER_ACL::TENANT
  end
  
  def land_lord?
    (role &  USER_ACL::LAND_LORD) ==  USER_ACL::LAND_LORD
  end
  
  def accountant?
    (role &  USER_ACL::ACCOUNTANT) ==  USER_ACL::ACCOUNTANT
  end
  
  def property_mgmt_mgr?
    (role &  USER_ACL::PROPERTY_MGMT_MGR) ==  USER_ACL::PROPERTY_MGMT_MGR
  end
  
  def property_mgmt_emp?
    (role &  USER_ACL::PROPERTY_MGMT_EMP) ==  USER_ACL::PROPERTY_MGMT_EMP
  end
  
  def agency_collection_emp?
    (role &  USER_ACL::AGENCY_COLLECTION_EMP) ==  USER_ACL::AGENCY_COLLECTION_EMP
  end
  
  def agency_collection_mgr?
    (role &  USER_ACL::AGENCY_COLLECTION_MGR) ==  USER_ACL::AGENCY_COLLECTION_MGR
  end

end




