class UserHouseContractPic < ActiveRecord::Base
  attr_accessible :user_house_contract_id, :picture, :about_pic, :primary_pic, 
                  :created_by, :updated_by, :created_at, :updated_at
                  
  belongs_to :user_house_contract

module HOUSE_PIC_SETTINGS
    DEFAULT_PIC_URL = "/system/:attachment/default.png" #"/images/:style/missing.png"
end

has_attached_file :picture, 
                    #:path => USER_AVATAR_SETTINGS::LOCATION,
                    #:url  => "/:attachment/:username.:extension",
                    styles: { medium: "300x300>", thumb: "100x100>" }, default_url: HOUSE_PIC_SETTINGS::DEFAULT_PIC_URL
  #validates_with AttachmentSizeValidator, attributes: :avatar, less_than: 1.megabytes
  validates_attachment :picture, 
        content_type: { content_type: ["image/jpeg", "image/gif", "image/png"] }, 
        size: { in: 0..5.megabytes }

end
