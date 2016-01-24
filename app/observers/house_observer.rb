class HouseObserver < ActiveRecord::Observer
  
  def after_create(house)
    puts "\n--------New House is created, lets make the created user as the owner.\n"
    make_user_house_owner(house)
  end

  def after_update(house)
    
  end
  
  def after_destroy(house)

  end

  private
  def make_user_house_owner (house)
    user_house_link = UserHouseLink.create(:user_id => house.created_by, :house_id => house.id,
                                         :role => User::USER_ACL::LAND_LORD, :created_by => house.created_by)
    if user_house_link.save
      puts "UserHouseLink has been created."
    end
  end
  
  #def send_new_user_email_notifiation (user)
  #  unless Rails.configuration.x.mg_client.nil?
  #    Rails.logger.info "send_new_user_email_notifiation::Trying to send email notification to" + user.email
  #    smtpSettings = Rails.configuration.app_config[:smtp]
  #    mailgunSettings = smtpSettings[:mailgun]
  #    puts "Sending email to " + user.email + ", from " + mailgunSettings[:from]
      
  #    notificationtype = NotificationType.find_by_ntype(NotificationType::TYPES::NEW_USER)
  #    unless (notificationtype.nil?)
  #      mail = Mail.deliver do
  #        to      user.email
  #        from    mailgunSettings[:from]
  #        subject notificationtype.subject
  #        text_part do
  #          body (notificationtype.content % user.fname)
  #        end
  #        content_type "text/html"
  #      end
  #      #Once all are successful, create a notification that the welcome! email is sent
  #      
  #    else
  #      Rails.logger.error "send_new_user_email_notifiation::smtp Welcome is not found. Couldn't send email to new user(id)=" + user.id        
  #    end
  #  else
  #    Rails.logger.error "send_new_user_email_notifiation::smtp configuation missing. Couldn't send email to new user(id)=" + user.id
  #  end
  #end
  #def add_user_to_salesforce_later(user)
  #  if Teambox.config.use_salesforce?
  #    Salesforce::Teambox::ClientEnqueuer.add(user)
  #  end
  #end

  #def update_salesforce_later(user)
  #  if Teambox.config.use_salesforce?
  #    Salesforce::Teambox::ClientEnqueuer.update(user)
  #  end
  #end

  #def remove_user_from_intercom(user)
  #  return if !Teambox.config.use_intercom?

  #  AsyncIntercom.enqueue user.id
  #end
end
