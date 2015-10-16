# Initialize your Mailgun object:
smtpSettings = Rails.configuration.app_config[:smtp]
Rails.configuration.x.isSmtpOutBoundEnabled = smtpSettings[:allow_outgoing_emails]
if Rails.configuration.x.isSmtpOutBoundEnabled
  mailgunSettings = smtpSettings[:mailgun]
  #mg_client = Mailgun::Client.new mailgunSettings[:api_key]
  #Rails.configuration.x.mg_client = mg_client
  
  delivery_options = { user_name: mailgunSettings[:user_name],
                         password: mailgunSettings[:password],
                         address: mailgunSettings[:address],
                         port: mailgunSettings[:port],
                         domain:  mailgunSettings[:domain],
                         authentication: "plain",
                         enable_starttls_auto: true,
                         openssl_verify_mode: 'none' 
                         }
  Rails.configuration.x.smtpDeliverOptions = delivery_options                         
  #Mail.defaults do
  #  delivery_method :smtp, {
  #    :port      => mailgunSettings[:port],
  #    :address   => mailgunSettings[:address],
  #    :user_name => mailgunSettings[:user_name],
  #    :password  => mailgunSettings[:password],
  #    :domain               => mailgunSettings[:domain],
  #    :authentication       => "plain",
  #    :enable_starttls_auto => true,
  #    :openssl_verify_mode  => 'none'
      #:return_response => true
  #  }
  #end
    
  puts "Successfully configured mail service"
else
  puts "Outbound email service is disabled!"    
end