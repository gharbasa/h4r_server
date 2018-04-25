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
           :description, :is_open

child(:land_lord => :land_lord) { attributes :id, :fullName}
child(:guest => :guest) { attributes :id, :fullName}           
child(:tenant => :tenant) { attributes :id, :fullName}
child(:accountant => :accountant) { attributes :id, :fullName}
child(:property_mgmt_mgr => :property_mgmt_mgr) { attributes :id, :fullName}
child(:property_mgmt_emp => :property_mgmt_emp) { attributes :id, :fullName}
child(:agency_collection_emp => :agency_collection_emp) { attributes :id, :fullName}
child(:agency_collection_mgr => :agency_collection_mgr) { attributes :id, :fullName}
child(:agency_collection_mgr => :agency_collection_mgr) { attributes :id, :fullName}
child(:community => :community) { attributes :id, :name}
