source 'https://rubygems.org'

#gem 'rails', '4.2.4'
#gem 'rack', '~> 10.4.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
#gem 'rails', '4.2.4'
gem 'rails', github: 'rails/rails', branch: '4-2-stable'
# Use sqlite3 as the database for Active Record
gem 'mysql2', '~> 0.3.18' #0.4.0 is not good
# use cancan gem for authorization acl
gem 'cancan'
gem 'rabl'
# Also add either `oj` or `yajl-ruby` as the JSON parser
gem 'oj'
gem 'authlogic'
gem 'bcrypt'
gem 'protected_attributes'
gem 'faker'
gem 'mail'
#gem 'mailgun-ruby', '~>1.0.3', require: 'mailgun'
#gem 'paperclip', "~> 4.3"
gem 'paperclip', "~> 5.1"
gem 'rails-observers' #removed from rails 4.0 onwards
#gem 'counter_culture', '~> 0.1.33'
#UI related gems
gem 'sass', '3.2.19' #3.4.18 is the latest, downgraded to 3.2.19 with 'bundle update sass'
gem 'bower-rails' # for angular-js
gem 'angular-rails-templates'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.0'
gem 'jbuilder', '~> 1.2'
gem 'sprockets', '2.12.3' #This is required for templates to work
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
gem "audited-activerecord", "~> 4.0"
gem 'aws-sdk', '~> 2.3'
gem 'rack-cors'
 
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

