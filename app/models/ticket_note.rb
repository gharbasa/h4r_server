class TicketNote < ActiveRecord::Base
  attr_accessible  :ticket_id, :note, :created_by, :updated_by,
                                :created_at, :updated_at, :private_note

  belongs_to :ticket
  belongs_to :createdBy, class_name: "User",foreign_key: "created_by"
  belongs_to :updatedBy, class_name: "User",foreign_key: "updated_by"
  scope :non_private_by_user, lambda { |user_id, ticket_id| where("(private != 1 or created_by=?) and ticket_id=?", user_id, ticket_id) }
  
  def private?
    :private_note
  end
end
