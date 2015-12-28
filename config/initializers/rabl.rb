require 'rabl'

Rabl.configure do |config|
  config.include_json_root = false
  config.include_child_root = false
  config.enable_json_callbacks = true

  # Don't recompile templates every time in production
  config.cache_sources = Rails.env != 'development'

  # Use rabl partial caching
  #config.perform_caching = Rails.configuration.perform_caching? # Default to rails configuration

  # Commented as these are defaults
  # config.cache_all_output = false
  # config.cache_engine = Rabl::CacheEngine.new # Defaults to Rails cache
  # config.escape_all_output = false
  # config.msgpack_engine = nil # Defaults to ::MessagePack
  # config.bson_engine = nil # Defaults to ::BSON
  # config.plist_engine = nil # Defaults to ::Plist::Emit
  # config.include_msgpack_root = true
  # config.include_bson_root = true
  # config.include_plist_root = true
  # config.include_xml_root  = false
  # config.include_child_root = true
  # config.xml_options = { :dasherize  => true, :skip_types => false }
  # config.view_paths = []
end
