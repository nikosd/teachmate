namespace(:subscription) do

  RAILS_ENV = 'development' unless RAILS_ENV
  require File.dirname(__FILE__) + '/../../config/environment'
  require 'subscription_mailer'

  task :mail do
    
  end

end
