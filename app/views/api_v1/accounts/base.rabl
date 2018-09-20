attributes :id,
           :baseline_amt, 
           :baseline_date, 
           :note, 
           :active, 
           :created_at, 
           :updated_at, 
           :created_by,
           :updated_by,
           :baselineDate,
           :unitsCount,
           :netAmount,
           :description

child(:createdBy => :createdBy) { attributes :fullName}
