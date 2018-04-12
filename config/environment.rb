# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!
Time::DATE_FORMATS[:custom_datetime] = Rails.configuration.app_config[:date_format] #"%d-%m-%Y"
