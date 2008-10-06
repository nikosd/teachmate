namespace(:subscription) do

  RAILS_ENV = 'development' unless RAILS_ENV
  require File.dirname(__FILE__) + '/../../config/environment'
  require 'subscription_mailer'

  task :mail do
    mailer = SubscriptionMailer.new

    mailer.find_subscriptions(1.day.ago)
    mailer.slice(:divider => 24)
    mailer.find_search_queries
    mailer.mail

    puts "Mails sent: #{mailer.last_run[:mails_sent]}"
  end

end
