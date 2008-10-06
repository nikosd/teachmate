config.cache_classes = true

config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

ActionMailer::Base.delivery_method = :sendmail
ActionMailer::Base.default_charset = 'utf-8'

AVATARS_PATH = "#{RAILS_ROOT}/public/avatars"
