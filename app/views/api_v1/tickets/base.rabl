attributes :id,
           :subject, 
           :description, 
           :status, 
           :active, 
           :created_by, 
           :created_by,
           :updated_by,
           :created_at, :updated_at,
           :notesCount
            
child(:createdBy => :createdBy) { attributes :fullName}
child(:updatedBy => :updatedBy) { attributes :fullName}           
