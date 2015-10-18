class CommunityObserver < ActiveRecord::Observer
  
  def after_create(community)
    #puts "\n--------New entry is added in user_house_link, lets notify house owner.\n"
    #notify_current_user_as_homeowner(user_house_link)
  end

  def after_update(community)
    puts "\n--------Updated community, lets notify manager/creator.\n"
    if(community.manager_id_changed?)
      #notify_change_in_userhouselink(user_house_link)
      notify_change_in_community(community,community.manager_id)
      if(community.manager_id_was.nil?)
        notify_change_in_community(community,community.created_by)
      else
        notify_change_in_community(community,community.manager_id_was)
      end
    else
      if(community.manager_id.nil?)
        notify_change_in_community(community,community.created_by)
      else  
        notify_change_in_community(community,community.manager_id)
      end  
    end
  end
  
  def after_destroy(user_house_link)
    
  end

  private
  def notify_change_in_community (community, user_id)
    notificationtype = NotificationType.findCommunityUpdatedNotification
    unless (notificationtype.nil?)
      notification = Notification.create(:user_id => user_id, :notification_type_id =>notificationtype.id,
                                         :retries_count => 0, :active => 1)
      if notification.save 
        puts "notify_change_in_community::UserNotification has been created."
        #UserMailer.house_verified(@house, @owner).deliver_now #deliver_later
      else
        puts "notify_change_in_community::ERROR:Problem creating UserNotification."
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
