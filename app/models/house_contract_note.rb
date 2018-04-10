class HouseContractNote < ActiveRecord::Base
  attr_accessible :note, :active, 
                  :created_by,:updated_by, :created_at, :updated_at,
                  :user_house_contract_id, :private

  alias_attribute :private_note, :private
  belongs_to :user_house_contract
  
  def deactivate!
    self.active = false
    save
  end  
end

