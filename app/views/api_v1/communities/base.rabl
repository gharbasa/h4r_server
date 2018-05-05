attributes :id,
           :name, 
           :addr1, 
           :addr2, 
           :addr3, 
           :addr4, 
           :processing_fee, 
           :verified, 
           :active,
           :manager_id,
           :created_by,
           :updated_by,
           :created_at, :updated_at,
           :unitsCount, :openUnits

child(:manager => :manager) { attributes :fullName}
child(:createdBy => :createdBy) { attributes :fullName}