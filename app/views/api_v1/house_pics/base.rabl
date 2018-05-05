attributes :id,
           :house_id, 
           :picture, 
           :about_pic, 
           :primary_pic, 
           :created_by, 
           :updated_by, 
           :created_at, 
           :updated_at
           
child(:house => :house) { attributes :name}