class HousePic < ActiveRecord::Base
  attr_accessible :house_id, :picture, :about_pic, :primary_pic, 
                  :created_by, :updated_by, :created_at, :updated_at
                  
  belongs_to :house

  has_attached_file :picture, 
                    :path => ":rails_root/public/system/:attachment/:house_id.:extension",
                    #:url  => "/:attachment/:username.:extension",
                    styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  #validates_with AttachmentSizeValidator, attributes: :avatar, less_than: 1.megabytes
  validates_attachment :picture, 
        content_type: { content_type: ["image/jpeg", "image/gif", "image/png"] }, 
        size: { in: 0..1.megabytes }

end