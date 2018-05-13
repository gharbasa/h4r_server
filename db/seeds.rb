# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'faker'
  SEED_OPTS = {
    :time_step => 2.minutes
  }

def fake_time
  @fake_time ||= 150.minutes.ago
  @fake_time += SEED_OPTS[:time_step]
end

NotificationType.create!(ntype: NotificationType::TYPES::NEW_USER, content: 'Wecome to MaaGhar, We are excited to have you in MaaGhar family. \nRegards MaaGhar Team',  
  require_retries: false, 
  active: true,
  subject: "Welcome to MaaGhar!"
)

NotificationType.create!(ntype: NotificationType::TYPES::HOUSE_VERIFIED, content: 'Congratulations and Thank you for giving us an opportunity to verify your house. We are excited to have you in MaaGhar family. \nRegards MaaGhar Team',  
  require_retries: false, 
  active: true,
  subject: "MaaGhar verified your house!"
)

NotificationType.create!(ntype: NotificationType::TYPES::USER_HOUSE_RECORD_UPDATED, content: 'There is a change in the house record you are associated with %s. \nRegards MaaGhar Team',  
  require_retries: false, 
  active: true,
  subject: "Change in house record!"
)

NotificationType.create!(ntype: NotificationType::TYPES::COMMUNITY_VERIFIED, content: 'Community has been verified and Thank you for giving us an opportunity to verify the community. We are excited to have you in MaaGhar family. \nRegards MaaGhar Team',  
  require_retries: false, 
  active: true,
  subject: "MaaGhar verified the community!"
)

NotificationType.create!(ntype: NotificationType::TYPES::COMMUNITY_UPDATED, content: 'There is a change in the Community. \nRegards MaaGhar Team',  
  require_retries: false, 
  active: true,
  subject: "Change in community!"
)

#Time.now.to_s :db
user = User.create!(login: 'abed', email: 'abedali@engineer.com',  
  password: "general1",
  password_confirmation: "general1",
  fname: "Abed", 
  mname: "", 
  lname: "Ali", 
  sex: User::USER_SEX::MALE,
  role: User::USER_ACL::ADMIN,
  addr1: "18 N Dorado Circle", 
  addr2: "Apt # 2B", 
  addr3: "Hauppauge", 
  addr4: "NY, USA", 
  phone1: "516-282-5964", 
  phone2: nil, 
  total_own_houses: 0, 
  total_houses_tenant: 0, 
  delete: 0, 
  created_by: nil, 
  updated_by: nil, 
  subscription_type:5,  #Admin default subscription
  #created_at: fake_time,
  #updated_at: nil
)
user.activate!
user.approve!
user.confirm!


