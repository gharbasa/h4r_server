class UserObserver < ActiveRecord::Observer
  
  require 'mail'
  
  def after_create(user)
    puts "\n--------New user is created, lets put a notification in his panel.\n"
    send_new_user_notification(user)
  end

  def after_update(user)
    #update_salesforce_later(user)
    puts "\n--------User is being updated.\n"
    if user.login_count_changed? && user.perishable_token_changed?
      puts "\n--------User model:: User did login.\n"
    end
    #puts user.changes
  end
  
  def after_destroy(user)
    #update_salesforce_later(user)
    #remove_user_from_intercom(user)
  end

  private
  def send_new_user_notification (user)
    notificationtype = NotificationType.findNewUserWelcomeNotification
    unless (notificationtype.nil?)
      notification = Notification.create(:user_id => user.id, :notification_type_id =>notificationtype.id,
                                         :retries_count => 0, :active => 1)
      if notification.save 
        puts "send_new_user_notification::UserNotification has been created."
      else
        puts "send_new_user_notification::ERROR:Problem creating UserNotification."
      end
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
