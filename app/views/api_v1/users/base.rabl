attributes :id,
           :email,
           :fname,
           :mname,
           :lname,
           :verified,
           :adhaar_no,
           :created_by,
           :updated_by,
           :avatar,
           :login,
           :phone1,
           :addr1,
           :addr2,
           :addr3,
           :addr4,
           :role,
           :sex,
           :fullName,
           :community_id,
           :subscriptionType,
           :subscriptionEndDate,
           :createdAt,
           :active
            
attributes :admin? => :admin,
           :guest? => :guest
            
child(:community => :community) { attributes :id, :name}
           