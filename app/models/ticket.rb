class Ticket < ActiveRecord::Base
  attr_accessible  :subject, :description, :status, :active, :created_by, :updated_by,
                                :created_at, :updated_at

  belongs_to :createdBy, class_name: "User",foreign_key: "created_by"
  belongs_to :updatedBy, class_name: "User",foreign_key: "updated_by"
  has_many :notes, class_name: "TicketNote"
  
  include ActiveFlag
  
  def deactivate!
    self.active = false
    save
  end
  
  def notesCount
    notes.count
  end

end
