attributes :id,
           :note, 
           :ticket_id,
           :private_note,
           :created_by,
           :updated_by,
           :createdAt, :updatedAt
           
child(:createdBy => :createdBy) { attributes :fullName}