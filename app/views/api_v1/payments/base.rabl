attributes :id,
           :user_house_contract_id, 
           :payment, 
           :payment_status, 
           :payment_type, 
           :retries_count, 
           :created_by, 
           :updated_by, 
           :note,
           :payment_date


child(user_house_contract.user => :user) { attributes :id, :fullName}
child(user_house_contract.house => :house) { attributes :id, :name}
child(user_house_contract.role => :role)
