class CommunityPic < ActiveRecord::Base
  attr_accessible :community_id, :picture, :about_pic, :primary_pic, :created_by, :updated_by

  belongs_to :community

  has_attached_file :picture, 
                    :path => ":rails_root/public/system/:attachment/:community_id.:extension",
                    #:url  => "/:attachment/:username.:extension",
                    styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  #validates_with AttachmentSizeValidator, attributes: :avatar, less_than: 1.megabytes
  validates_attachment :picture, 
        content_type: { content_type: ["image/jpeg", "image/gif", "image/png"] }, 
        size: { in: 0..1.megabytes }

end