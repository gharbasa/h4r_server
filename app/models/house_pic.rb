class HousePic < ActiveRecord::Base
  attr_accessible :house_id, :picture, :about_pic, :primary_pic, 
                  :created_by, :updated_by, :created_at, :updated_at,:rekognition_labels, :rekognition_text
                  
  belongs_to :house

module HOUSE_PIC_SETTINGS
    DEFAULT_PIC_URL = "/system/:attachment/default.png" #"/images/:style/missing.png"
    PROHIBITED_CONTENT = {"Human" => 60, "People" => 60, "Person" => 60, "Baby"=> 50, "Child"=> 50, "Kid" => 50}
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
