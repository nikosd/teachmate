require 'advanced_file_store_caching'
# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
ActionController::Base.cache_store = :advanced_file_store, "#{RAILS_ROOT}/public/cache/"
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = true #should be false
config.action_view.cache_template_loading            = true #should be false
# config.action_view.cache_template_extensions         = false #deprecated

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = true

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.default_charset = 'utf-8'
  
AVATARS_PATH = "#{RAILS_ROOT}/public/images/avatars"
