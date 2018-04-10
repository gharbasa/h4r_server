attributes :id,
           :name, 
           :addr1, 
           :addr2, 
           :addr3, 
           :addr4, 
           :no_of_portions, 
           :no_of_floors, 
           :verified, 
           :processing_fee,
           :community_id,
           :active,
           :created_by,
           :updated_by,
           :created_at, :updated_at,
           :description

child(:land_lord => :land_lord) { attributes :id, :fname,  :lname}
child(:guest => :guest) { attributes :id, :fname,  :lname}           
child(:tenant => :tenant) { attributes :id, :fname,  :lname}
child(:accountant => :accountant) { attributes :id, :fname,  :lname}
child(:property_mgmt_mgr => :property_mgmt_mgr) { attributes :id, :fname,  :lname}
child(:property_mgmt_emp => :property_mgmt_emp) { attributes :id, :fname,  :lname}
child(:agency_collection_emp => :agency_collection_emp) { attributes :id, :fname,  :lname}
child(:agency_collection_mgr => :agency_collection_mgr) { attributes :id, :fname,  :lname}
child(:agency_collection_mgr => :agency_collection_mgr) { attributes :id, :fname,  :lname}
