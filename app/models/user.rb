require 'bcrypt'
class User < ActiveRecord::Base
  attr_accessible :email, :password, :fname, :mname, :lname, :password_confirmation, :login, 
                    :role, :addr1, :addr2, :addr3, :addr4, :phone1, :phone2, :sex,
                    :adhaar_no, :verified, 
                    :active, :approved, :confirmed, :ndelete, :created_by, :updated_by, 
                    :avatar

  include ActiveFlag
  
  has_many :user_house_links
  has_many :houses, through: :user_house_links
  has_many :notifications
  has_many :communities, class_name: "Community", foreign_key: "manager_id"
  
  #default location of avatars are /Users/abedali/eclipse/workspace1/h4r_backend/public/system/users/avatars/000/000/001  
  has_attached_file :avatar, 
                    :path => ":rails_root/public/system/:attachment/:username.:extension",
                    #:url  => "/:attachment/:username.:extension",
                    styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  #validates_with AttachmentSizeValidator, attributes: :avatar, less_than: 1.megabytes
  validates_attachment :avatar, 
        content_type: { content_type: ["image/jpeg", "image/gif", "image/png"] }, 
        size: { in: 0..1.megabytes }
  
  module USER_ACL
    GUEST        = 0 #default
    ADMIN        = 1 << 16 #100000000=256
    TENANT       = 1 << 15 #010000000
    LAND_LORG    = 1 << 14 #001000000
    ACCOUNTANT   = 1 << 13
    PROPERTY_MGMT_MGR = 1 << 12 #Property management manager
    PROPERTY_MGMT_EMP  = 1 << 11 #Property management employee
    AGENCY_COLLECTION_EMP    = 1 << 10 #Collection agency emp
    AGENCY_COLLECTION_MGR    = 1 << 9 #Collection agency mgr
  end
  
  module USER_SEX
    DEFAULT       = 0,
    MALE          = 1,
    FEMALE        = 2
  end
  
  #belongs_to :created_by_user, :foreign_key => 'created_by'
  #belongs_to :updated_by_user, :foreign_key => 'updated_by'
  
#  SEED_OPTS = {
#  :organizations => 50,
#}

  include BCrypt
  acts_as_authentic do |c|
    #c.my_config_option = my_value
    #c.login_field = :username
    c.crypto_provider = Authlogic::CryptoProviders::BCrypt
    c.validates_format_of_email_field_options = {:with => Authlogic::Regex.email_nonascii}
  end # the configuration block is optional
  
  def admin?
    #print "Lets check if the user is admin=" + acl.to_s + ":" + (acl & USER_ACL::ADMIN).to_s
    (role & USER_ACL::ADMIN) == USER_ACL::ADMIN
  end
  
  def guest?
    (role & USER_ACL::GUEST) == USER_ACL::GUEST
  end
  
  def tenant?
    (role & USER_ACL::TENANT) == USER_ACL::TENANT
  end
  
  def land_lord?
    (role & USER_ACL::LAND_LORD) == USER_ACL::LAND_LORD
  end
  
  def accountant?
    (role & USER_ACL::ACCOUNTANT) == USER_ACL::ACCOUNTANT
  end
  
  def property_mgmt_mgr?
    (role & USER_ACL::PROPERTY_MGMT_MGR) == USER_ACL::PROPERTY_MGMT_MGR
  end
  
  def property_mgmt_emp?
    (role & USER_ACL::PROPERTY_MGMT_EMP) == USER_ACL::PROPERTY_MGMT_EMP
  end
  
  def agency_collection_emp?
    (role & USER_ACL::AGENCY_COLLECTION_EMP) == USER_ACL::AGENCY_COLLECTION_EMP
  end
  
  def agency_collection_mgr?
    (role & USER_ACL::AGENCY_COLLECTION_MGR) == USER_ACL::AGENCY_COLLECTION_MGR
  end
  
  def otherRole?
    !(admin? && guest? && tenant? && land_lord? && accountant? &&
      property_mgmt_mgr? && property_mgmt_emp? && agency_collection_emp? && agency_collection_mgr?)
  end
  
  #check if the user is a owner of this house (param)
  def owner? (house)
    user_house_links.each do |user_house_link|
            return true if user_house_link.house.id == house.id &&
                     user_house_link.user.id == id &&
                     user_house_link.owner?
    end
    return false
  end
  
  #check if the user is a manager of community(param)
  def manager? (community)
    community.manager_id == id
  end
  
  #check if the user has created this community(param)
  def created? (community)
    community.created_by == id
  end
  
  def verified?
    verified
  end
  def male?
    sex == USER_SEX::MALE
  end
  
  def female?
    sex == USER_SEX::FEMALE
  end
  
  def active?
    active
  end
  
  def approved?
    approved
  end
  
  def confirmed?
    confirmed
  end
  
#  def activate!
#    update_attributes(:active => true) #, :approved =>true, :confirmed => true)
#  end

  def activate!
    self.active = true
    save
  end
  
  def approve!
    self.approved = true
    save
  end
  
  def confirm!
    self.confirmed = true
    save
  end
  
  def inactive?
    ndelete
  end
  
  def deactivate!
    self.ndelete = true
    save
  end
  #def password
  #  @password ||= Password.new(password_hash)
  #end
  
  #def password=(new_password)
  #  @password = Password.create(new_password)
  #  self.password_hash = @password
  #end
  
end