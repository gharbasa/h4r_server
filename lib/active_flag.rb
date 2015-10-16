module ActiveFlag 
    extend ActiveSupport::Concern 
   ACTIVE = 1
   INACTIVE = 0
   
   def active?
     active == ACTIVE
   end
end
