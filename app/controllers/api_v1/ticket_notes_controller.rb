class ApiV1::TicketNotesController < ApiV1::BaseController
  before_filter :require_user, :only => []
  skip_before_action :verify_authenticity_token
  before_filter :load_user, :only => [:index, :show, :destroy, :create]
  before_filter :load_ticket, :only => [:index, :show, :destroy, :create]
  
  def index
    if(@ticket)
       if(current_user.admin?)
         @notes = @ticket.notes.order(created_at: :desc) #ticket owner can view all the ticket notes
       else
         @notes = TicketNote.non_private_by_user(current_user.id, @ticket.id).order(created_at: :desc)  #Non-ticket owner can only view public and his created notes.
       end
    else
      @errMsg = "Ticket not found."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def create
      if(@ticket)  
        @note = TicketNote.create(:ticket_id => @ticket.id,
                                  :note => params[:note],
                                  :created_by => current_user.id,
                                  :private_note => params[:private_note]
                                  )
        if(@note.save)
          render 'show', :status => :created  
        else
          @errMsg = @ticket.errors.full_messages
          print @errMsg 
          render 'error', :status => :unprocessable_entity  
        end
      else
        @errMsg = "Ticket not found."
        print @errMsg 
        render 'error', :status => :unprocessable_entity
      end
  end
 
  def destroy
    @ticketnote = TicketNote.find(params[:id])
    if isAuth
      @ticketnote.delete 
      render 'destroy', :status => :ok
    else
      @errMsg = "User is neither admin nor ticket owner."
      print @errMsg 
      render 'error', :status => :unprocessable_entity
    end
  end
  
  def load_ticket
    ticket_id = params[:ticket_id]
    if ticket_id
      @ticket = Ticket.find(ticket_id)
    end
  end
  
  def load_user
    user_id = params[:user_id]
    if user_id
      @user = User.find(user_id)
    end
  end
  def isAuth  # only ticket owner or admin can update ticket
    current_user.admin? || (@ticket.created_by == current_user.id)
  end
  
end
