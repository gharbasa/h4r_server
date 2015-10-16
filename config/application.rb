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
    
    #Register observers here
    #active_observers = Dir["app/observers/*"].map do |i|
    #                     File.basename(i, ".rb")
    #                     puts File.basename(i, ".rb")
    #end
    config.active_record.observers = :user_observer, :house_observer, :user_house_link_observer
  end
end
