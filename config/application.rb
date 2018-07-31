require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module H4R #This is a namespace for routes.rb
  def self.config
    Rails.configuration
  end
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    #config.paths['config/routes'].concat Dir[Rails.root.join("config/routes/**/*.rb")]
    config.autoload_paths += %W(#{config.root}/lib 
                                #{config.root}/app/observers)
                                
    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    config.action_controller.permit_all_parameters = true
    #config.filter_parameters += [:password, :password_confirmation]
    #config.assets.compile = true
    #config.serve_static_files = true
    #UI related angular js includes
    config.assets.paths << Rails.root.join("vendor","assets","bower_components")
    config.assets.paths << Rails.root.join("vendor","assets","bower_components","bootstrap-sass-official","assets","fonts")
    config.assets.precompile << %r(.*.(?:eot|svg|ttf|woff|woff2)$)
    #config.assets.precompile += %w( *.js *.css )
    
    def config.load_h4r_config
      self.app_config = Rails.application.config_for(:h4r).deep_symbolize_keys
    end
    config.load_h4r_config

    Aws::VERSION =  Gem.loaded_specs["aws-sdk"].version
    #AWS Configuration
    Aws.config.update({
      credentials: Aws::Credentials.new(Rails.configuration.app_config[:AWS_KEY], Rails.configuration.app_config[:AWS_SECRET])
    })
    Aws.config.update({region: Rails.configuration.app_config[:AWS_REGION]})
    Aws.config.update({log_level: :debug})
  
    config.paperclip_defaults = {
      :storage => :s3,
      :preserve_files => true,
      :s3_region => Rails.configuration.app_config[:AWS_REGION],
      #:s3_host_name => 'REMOVE_THIS_LINE_IF_UNNECESSARY',
      :bucket => 'maaghar'
    }
    
    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins Rails.configuration.app_config[:CLIENT_DOMAIN]
        resource '*', headers: :any, methods: [:get, :post, :options, :put, :delete], credentials: true
      end
    end
    
    def config.load_cloudsearch_config
      #https://docs.aws.amazon.com/sdkforruby/api/Aws/CloudSearch/Client.html#describe_domains-instance_method
      #Identify endpoints for cloudsearch
      #https://docs.aws.amazon.com/cloudsearch/latest/developerguide/what-is-cloudsearch.html
      self.awsCSClient = Aws::CloudSearch::Client.new(region: Rails.configuration.app_config[:AWS_CS_REGION])
      resp = self.awsCSClient.describe_domains({domain_names: [Rails.configuration.app_config[:CS_DOMAIN_NAME]]})
      resp[:domain_status_list].each do |domain|
        puts domain[:domain_id]
      end
      
      self.awsCSDomainClientForAdd = client = Aws::CloudSearchDomain::Client.new(endpoint:Rails.configuration.app_config[:CS_UPLOAD_DOCS_ENDPOINT])
      self.awsCSDomainClientForSearch = client = Aws::CloudSearchDomain::Client.new(endpoint:Rails.configuration.app_config[:CS_SEARCH_DOCS_ENDPOINT])
      
    end
    config.load_cloudsearch_config
    
    
    
    #resp = csClient.build_suggesters({
    #  domain_name: "maaghar" # required
    #})
    #puts "Abed.field_names..:" . resp.field_names #=> Array
    #puts "Abed.field_names[0]..:" . resp.field_names[0] #=> String


    #Register observers here
    #active_observers = Dir["app/observers/*"].map do |i|
    #                     File.basename(i, ".rb")
    #                     puts File.basename(i, ".rb")
    #end
    config.active_record.observers = :user_observer, :house_observer, :user_house_link_observer, :community_observer
  end
end
