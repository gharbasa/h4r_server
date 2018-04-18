# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150827030447) do

  create_table "tests", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.text     "text",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end
  
  create_table :users do |t|
    # Authlogic::ActsAsAuthentic::Email
    t.string    :login,               :null => false                # optional, you can use email instead, or both
    t.string    :email,               :null => false                # optional, you can use login instead, or both
    t.string    :crypted_password,    :null => false                # optional, see below
    t.string    :password_salt,       :null => false                # optional, but highly recommended
    t.string    :persistence_token,   :null => false                # required
    t.string    :single_access_token, :null => false                # optional, see Authlogic::Session::Params
    t.string    :perishable_token,    :null => false                # optional, see Authlogic::Session::Perishability

    # Magic columns, just like ActiveRecord's created_at and updated_at. These are automatically maintained by Authlogic if they are present.
    t.integer   :login_count,         :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
    t.integer   :failed_login_count,  :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
    t.datetime  :last_request_at                                    # optional, see Authlogic::Session::MagicColumns
    t.datetime  :current_login_at                                   # optional, see Authlogic::Session::MagicColumns
    t.datetime  :last_login_at                                      # optional, see Authlogic::Session::MagicColumns
    t.string    :current_login_ip                                   # optional, see Authlogic::Session::MagicColumns
    t.string    :last_login_ip                                      # optional, see Authlogic::Session::MagicColumns

    t.string    :fname,               :null => false
    t.string    :mname,               :null => false
    t.string    :lname,               :null => false
    t.integer   :sex,              :default => 0 #1-male, 2-female, 0-none
    t.integer   :role,                 :null => false, :default => User::USER_ACL::GUEST #default-guest Summation of all roles in the link tables, except admin.
    t.string     :addr1,               :null => false   #street name/colony name
    t.string     :addr2                                #house number
    t.string     :addr3                                #town/city name
    t.string     :addr4                                #state
    t.string    :phone1,              :null => false #Primary phone number
    t.string    :phone2                               # Secondary phone number
    t.integer   :total_own_houses,          :default => 0 #Number houses user owns
    t.integer   :total_houses_tenant,     :default => 0 #Number houses user is a tenant
    t.datetime  :dob
    t.string    :avatar  #URL of the user's avatar
    t.boolean   :ndelete, :default => false#Is user de-activated?
    # Authlogic::Session::MagicStates 
    t.boolean   :active, default: false
    t.boolean   :approved, default: false
    t.boolean   :confirmed, default: false
    t.string   :adhaar_no
    t.attachment :avatar
    t.boolean    :verified,            :default => false #Verify the user?, this flag is visible only for admin UI
    t.integer   :created_by  #user_id
    t.integer   :updated_by  #user_id
    t.timestamps
  end
  
  create_table :houses do |t|
    t.string      :name,                :null => false
    t.string      :addr1,               :null => false   #street name/colony name
    t.string      :addr2,               :null => false   #house number
    t.string      :addr3,               :null => false    #town/city name
    t.string      :addr4,               :null => false    #state
    t.string      :description,         :null => true     #state
    t.integer     :no_of_portions,      :default => 1
    t.integer     :no_of_floors,        :default => 1
    t.integer     :total_pics,          :default => 0
    t.float       :processing_fee,      :default => 0
    t.boolean     :verified,            :default => false #Verify house address
    t.boolean    :active,          :default => true #House active?
    t.integer    :community_id    #Can be null
    t.integer    :created_by  #user_id
    t.integer    :updated_by  #user_id
    t.timestamps
  end
  
  create_table :communities do |t|
    t.string     :name,                :null => false
    t.string     :addr1,               :null => false   #street name/colony name
    t.string     :addr2,               :null => false   #house number
    t.string     :addr3,               :null => false    #town/city name
    t.string     :addr4,               :null => false    #state
    t.integer    :total_pics,          :default => 0
    t.float      :processing_fee,      :default => 0
    t.boolean    :verified,            :default => false #Verify house address
    t.boolean   :active,          :default => true #House active?
    t.integer   :manager_id   #users table
    t.integer   :created_by  #user_id
    t.integer   :updated_by  #user_id
    t.timestamps
  end
  
  create_table :community_pics do |t|    #
    t.integer             :community_id,               :null => false
    t.attachment :picture
    t.string              :about_pic,               :null => false #About the pic
    t.boolean             :primary_pic,  :default => false
    t.integer   :created_by
    t.integer   :updated_by
    t.timestamps
  end
  
  create_table :house_pics do |t|    #
    t.integer             :house_id,               :null => false
    t.attachment :picture
    t.string              :about_pic,               :null => false #About the pic
    t.boolean             :primary_pic,  :default => false
    t.integer   :created_by
    t.integer   :updated_by
    t.timestamps
  end
  
  create_table :house_notes do |t|    #
    t.integer             :house_id,               :null => false
    t.text              :note,                     :null => false
    t.boolean             :active,                 :default => true
    t.boolean             :private,                 :default => false
    t.integer   :created_by
    t.integer   :updated_by
    t.timestamps
  end
  
  create_table :property_mgmts do |t|    #Property management companies
    t.string     :name,                :null => false
    t.string     :addr1,               :null => false   #street name/colony name
    t.string     :addr2,               :null => false   #house number
    t.string     :addr3,               :null => false    #town/city name
    t.string     :addr4,               :null => false    #state
    t.string     :webpage
    t.integer    :total_employees,      :default => 0
    t.boolean    :active,          :default => true  #House active?
    t.integer    :created_by                       
    t.integer    :updated_by                       
    t.timestamps
  end
  
  create_table  :user_house_links do |t|    #
    t.integer     :user_id,                 :null => false
    t.integer     :house_id,                :null => false
    t.integer     :role,                    :null => false, :default => User::USER_ACL::GUEST
    t.float       :processing_fee,          :default => 0   #can be user level or house level.
    t.integer     :total_renewals,          :default => 0 # number of user_house_contracts
    t.integer     :total_pending_payments,          :default => 0 #
    t.integer     :total_fail_payments,          :default => 0 #
    t.integer     :total_success_payments,          :default => 0 #
    t.integer     :user_house_contract_id , :default => 0 #There could be renewals, current active one.
    t.boolean     :active,                  :default => true #user house relation active?
    t.integer     :created_by
    t.integer     :updated_by
    t.timestamps
  end
  
  #The {user_id, house_id, role}  These combinations are generated from user_house_links while creating a contract
  #This table don't refer to user_house_links table, reason user and house associations may change after signing the contract.
  create_table    :user_house_contracts do |t|    #Contract between user and house
    t.integer     :user_id,                 :null => false
    t.integer     :house_id,                :null => false
    t.integer     :role,                :null => false 
    t.datetime    :contract_start_date, :null => false
    t.datetime    :contract_end_date,   :null => false
    t.float       :annual_rent_amount,     :default => 0  #Rent amount during contract sign-up
    t.float       :monthly_rent_amount,     :default => 0  #Rent amount during contract sign-up
    t.string      :note,                :null => true
    t.boolean :active,          :default => true #is house is in contract active?
    t.integer     :created_by
    t.integer     :updated_by
    t.timestamps
    t.integer     :user_house_link_id,  :null => true #This can be null, it is only a reference to track back to the user/house association
    t.integer     :next_contract_id,    :null => true #The contract renwed out of the present contract.
  end
  
  create_table :payments do |t|   #Payment transactions
    t.integer  :user_house_contract_id, :null => false
    t.float    :payment,                :null => false
    t.integer  :payment_status,         :default => 0 #pending, complete, failed
    t.integer  :payment_type,           :default => 0 #initial payment for showing house? or rent payment
    t.integer  :retries_count,          :default => 0 #retries on failed payments, max.retries will be in the application
    t.string   :note,                   :null => true
    t.timestamps :payment_date,         :null => false
    t.boolean    :active,          :default => true #House active?
    t.integer    :created_by
    t.integer    :updated_by
    t.timestamps
  end

  create_table :house_contract_notes do |t|    #
    t.integer    :user_house_contractId,  :null => false
    t.text       :note,                     :null => false
    t.boolean    :active,                 :default => true
    t.boolean    :private,                 :default => false #only administrator will see it
    t.integer   :created_by
    t.integer   :updated_by
    t.timestamps
  end
  
  create_table :user_house_contract_pics do |t|    #
    t.integer    :user_house_contract_id,    :null => false
    t.attachment :picture
    t.string     :about_pic,               :null => false #About the pic
    t.boolean    :primary_pic,  :default => false
    t.integer   :created_by
    t.integer   :updated_by
    t.timestamps
  end
  
  create_table    :user_property_mgmt_links do |t|    #
    t.integer     :user_id,             :null => false
    t.integer     :property_mgmt_id,    :null => false   
    t.integer     :role,               :null => false #property manager? or employee? 
    t.integer     :created_by
    t.integer     :updated_by
    t.timestamps
  end
  
  create_table :agency_collections do |t|    #Collection Agency respnsible for collecting money
    t.string     :name,                :null => false
    t.string     :addr1,               :null => false   #street name/colony name
    t.string     :addr2,               :null => false   #house number
    t.string     :addr3,               :null => false    #town/city name
    t.string     :addr4,               :null => false    #state
    t.string     :webpage
    t.boolean    :active,          :default => true  #House active?
    t.integer    :total_employees,     :default => 0
    t.integer    :created_by
    t.integer    :updated_by
    t.timestamps
  end
  
  create_table :user_agency_collection_links do |t|    #Employee in Collection Agency
    t.integer     :user_id,                :null => false
    t.integer     :agency_collection_id,   :null => false
    t.integer     :role,                   :null => false
    
    t.integer    :created_by
    t.integer    :updated_by
    t.timestamps
  end
 
  create_table :notifications do |t|   #Rent payment notification/notification to collection agency
    t.integer  :user_id,                    :null => false  #notification to user Id
    t.integer  :notification_type_id,       :default => 0 
    t.integer  :retries_count,              :default => 0 #retries on failed payments, max.retries will be in the application
    t.boolean  :active,          :default => true  #Notification active?
    t.integer  :priority,          :default => Notification::PRIORITY::NORMAL
    t.integer  :created_by
    t.integer  :updated_by
    t.timestamps
  end
  
  create_table :notification_types do |t|   #
    t.integer  :ntype,                    :default => 0 #type of notification rent reminder/general/collection agent notification
    t.string  :content                   #content can have ${} notation to replace with appropriate variable data
    t.string :subject,                   :default => "Notification from H4R"
    t.boolean :require_retries,          :default => 0  #Does this type of notification require retries?
    t.boolean    :active,          :default => true  #Notification type active?
    t.integer    :created_by
    t.integer    :updated_by
    t.timestamps
  end
end
