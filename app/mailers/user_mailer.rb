class UserMailer < ApplicationMailer
  #default from: 'notifications@example.com'

  def welcome_email(user)
    @user = user
    #@url  = 'http://www.h4r.com/login'
    notificationtype = NotificationType.findNewUserWelcomeNotification
    unless (notificationtype.nil?)
      if Rails.configuration.x.isSmtpOutBoundEnabled
      
        mail(to: @user.email, subject: notificationtype.subject, content_type: "text/html", 
                delivery_method_options: Rails.configuration.x.smtpDeliverOptions)
      else
        puts "UserMailer::welcome_email-outbound email service disabled."
      end
    end
  end
  
  def house_verified(house, owner)
    @owner = owner
    @house = house
    #@url  = 'http://www.h4r.com/login'
    notificationtype = NotificationType.findHouseVerifiedNotification
    unless (notificationtype.nil?)
      if Rails.configuration.x.isSmtpOutBoundEnabled
      
        mail(to: @owner.email, subject: notificationtype.subject, content_type: "text/html", 
                delivery_method_options: Rails.configuration.x.smtpDeliverOptions)
      else
        puts "UserMailer::house_verified-outbound email service disabled."
      end
    else
      puts "ERR UserMailer::house_verified-Template not found in db."
    end
  end
end
