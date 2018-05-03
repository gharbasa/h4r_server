class HouseContractNote < ActiveRecord::Base
  attr_accessible :note, :active, 
                  :created_by,:updated_by, :created_at, :updated_at,
                  :user_house_contract_id, :private

  alias_attribute :private_note, :private
  belongs_to :user_house_contract
  include DatetimeFormat
  
  scope :non_private_by_user_contract, lambda { |user_id, contract_id| where("(private != 1 or created_by=?) and user_house_contract_id=?", user_id, contract_id) }
  
  def deactivate!
    self.active = false
    save
  end  
end

