class ApplicationMailer < ActionMailer::Base
  smtpSettings = Rails.configuration.app_config[:smtp]
  mailgunSettings = smtpSettings[:mailgun]
  default from: mailgunSettings[:from]

  layout 'mailer'
end
