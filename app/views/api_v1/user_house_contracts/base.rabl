attributes :id,
           :user_id, :house_id, :role,
           :contract_start_date, 
           :contract_end_date, 
           :annual_rent_amount, :monthly_rent_amount, :active, :created_by, :updated_by,
           :created_at, :updated_at, :note


child(:user => :user) do
	attributes :fullName
end

child(:house => :house) do
  attributes :name
end

attributes  :tenant? => :tenant,
            :land_lord? => :land_lord,
            :accountant? => :accountant,
            :property_mgmt_mgr? => :property_mgmt_mgr,
            :property_mgmt_emp? => :property_mgmt_emp,
            :agency_collection_emp? => :agency_collection_emp,
            :agency_collection_mgr? => :agency_collection_mgr
