attributes  :id, 
            :user_id, 
            :house_id, 
            :role, 
            :processing_fee, 
            :total_renewals, 
            :total_pending_payments, 
            :total_fail_payments, 
            :total_success_payments, 
            :user_house_contract_id , 
            :active,
            :created_by, 
            :updated_by

child(:user => :user) { attributes :id, :fullName}
child(:house => :house) { attributes :id, :name, :verified}

attributes  :tenant? => :tenant,
            :land_lord? => :land_lord,
            :accountant? => :accountant,
            :property_mgmt_mgr? => :property_mgmt_mgr,
            :property_mgmt_emp? => :property_mgmt_emp,
            :agency_collection_emp? => :agency_collection_emp,
            :agency_collection_mgr? => :agency_collection_mgr,
            :maintenance? => :maintenance
            